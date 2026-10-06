import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:protocol/protocol.dart';

void main() {
  // DefaultLayout is the fallback for every failure path — unreadable storage,
  // a rejected drag, an unfinished edit — so its invariants are load-bearing
  // rather than a formality. If these fail, reset is no longer a safe answer.

  group('the default layout', () {
    final layout = DefaultLayout.layout;

    test('has all sixteen elements, once each', () {
      expect(layout.elements.keys, unorderedEquals(PadElement.ids));
      expect(PadElement.ids, hasLength(16));
    });

    test('has no two elements overlapping', () {
      expect(layout.isValid, isTrue, reason: layout.toString());
    });

    test('keeps every element inside the canvas', () {
      for (final element in layout.ordered) {
        expect(
          element.rect.right,
          lessThanOrEqualTo(layout.authoredSize.width),
          reason: '${element.id} runs off the right edge',
        );
        expect(
          element.rect.bottom,
          lessThanOrEqualTo(layout.authoredSize.height),
          reason: '${element.id} runs off the bottom',
        );
      }
      expect(layout.isWithinCanvas, isTrue);
    });

    test('satisfies its own constraints, element by element', () {
      // Checked by round-tripping rather than by re-deriving each type's rule
      // here, so this test cannot drift from the constraints it is asserting.
      // A default layout that `constrain` would move is a default layout the
      // editor cannot start from.
      for (final element in layout.ordered) {
        final constrained = element.constrain(
          element.rect,
          layout.authoredSize,
        );

        expect(constrained, element.rect, reason: element.id);
        expect(
          element.minSize.contains(element.fit(element.rect.width)),
          isTrue,
          reason: element.id,
        );
      }

      for (final element in layout.ordered) {
        switch (element) {
          case DpadElement() || StickElement():
            expect(element.rect.width, element.rect.height, reason: element.id);
          case TriggerElement():
            expect(element.rect.size, TriggerElement.fixedSize);
          case ButtonElement():
            break;
        }
      }
    });

    test('gives no ids to the four d-pad directions of their own', () {
      // They are one group on screen and one hat on the wire, so a separate
      // element would be able to press UP from outside that group.
      for (final id in ['UP', 'DOWN', 'LEFT', 'RIGHT']) {
        expect(layout[id], isNull);
        expect(() => PadElement.fromId(id, Rect.zero), throwsFormatException);
      }
    });
  });

  group('place', () {
    final layout = DefaultLayout.layout;
    final guide = layout['GUIDE']!;

    test('returns the same instance when nothing moved', () {
      expect(layout.place('GUIDE', guide.rect), same(layout));
    });

    test('moves an element and leaves the others alone', () {
      final moved = layout.place(
        'GUIDE',
        guide.rect.shift(const Offset(20, 0)),
      );

      expect(moved['GUIDE']!.rect, guide.rect.shift(const Offset(20, 0)));
      expect(moved['LB'], layout['LB']);
      expect(moved.elements.length, layout.elements.length);
    });

    test('keeps an element inside the canvas rather than off it', () {
      final moved = layout.place(
        'GUIDE',
        guide.rect.shift(const Offset(10_000, 10_000)),
      );

      expect(moved['GUIDE']!.rect.right, moved.authoredSize.width);
      expect(moved['GUIDE']!.rect.bottom, moved.authoredSize.height);
    });

    test('keeps a button above the minimum thumb size', () {
      final squashed = layout.place('A', guide.rect.deflate(1000));

      expect(squashed['A']!.rect.width, 44);
      expect(squashed['A']!.rect.height, 44);
    });

    test('resizes width and height independently', () {
      final stretched = layout.place(
        'A',
        Rect.fromLTWH(guide.rect.left, guide.rect.top, 200, 50),
      );

      expect(stretched['A']!.rect.size, const Size(200, 50));
    });

    test('collapses a stick to square on a diagonal drag', () {
      final resized = layout.place(
        'leftStick',
        Rect.fromLTWH(
          layout['leftStick']!.rect.left,
          layout['leftStick']!.rect.top,
          300,
          150,
        ),
      );

      expect(resized['leftStick']!.rect.width, 300, reason: 'larger axis wins');
      expect(resized['leftStick']!.rect.height, 300);
    });

    test('leaves a trigger its fixed size however it is dragged', () {
      final resized = layout.place('LT', Rect.fromLTWH(0, 0, 400, 200));

      expect(resized['LT']!.rect.size, TriggerElement.fixedSize);
      expect(resized['LT']!.resizable, isFalse);
    });

    test('does not reject an overlap — that is the caller\'s job', () {
      // The editor draws an invalid drag in the error colour and reverts on
      // release, so the intermediate layout has to exist.
      final onTop = layout.place('A', layout['LB']!.rect);

      expect(onTop['A']!.rect, layout['LB']!.rect);
      expect(onTop.isValid, isFalse);
      expect(layout.isValid, isTrue, reason: 'the original is untouched');
    });

    test('rejects an unknown id', () {
      expect(() => layout.place('NOPE', Rect.zero), throwsArgumentError);
    });
  });

  group('validity', () {
    test('overlap is detected by touching edges alone', () {
      final layout = DefaultLayout.layout;
      final guide = layout['GUIDE']!;

      // Immediately right of GUIDE, sharing an edge and no pixels.
      final flush = layout.place(
        'LS',
        Rect.fromLTWH(guide.rect.right, guide.rect.top, 90, 44),
      );
      expect(flush.collides(flush['LS']!.rect, except: 'LS'), isFalse);
      expect(flush.isValid, isTrue);

      final overlapping = layout.place(
        'LS',
        Rect.fromLTWH(guide.rect.right - 1, guide.rect.top, 90, 44),
      );
      expect(overlapping.isValid, isFalse);
    });

    test('reports the ids it collides with', () {
      final layout = DefaultLayout.layout;

      expect(layout.collides(layout['A']!.rect), isTrue);
      expect(
        layout.collides(layout['A']!.rect, except: 'A'),
        isFalse,
        reason: 'nothing else is near A',
      );
      expect(
        layout.collides(Rect.fromLTWH(400, 380, 20, 20)),
        isFalse,
        reason: 'empty corner',
      );
    });
  });

  group('elementAt', () {
    final layout = DefaultLayout.layout;

    test('finds the element under a point', () {
      expect(layout.elementAt(layout['A']!.rect.center)?.id, 'A');
      expect(layout.elementAt(layout['dpad']!.rect.center)?.id, 'dpad');
      expect(
        layout.elementAt(layout['leftStick']!.rect.center)?.id,
        'leftStick',
      );
    });

    test('returns null for empty canvas', () {
      expect(layout.elementAt(Offset.zero), isNull);
    });
  });

  group('construction', () {
    test('requires exactly the sixteen ids', () {
      final complete = DefaultLayout.layout.elements;

      expect(
        () => ControllerLayout(
          authoredSize: DefaultLayout.canvasSize,
          elements: {...complete}..remove('A'),
        ),
        throwsArgumentError,
      );

      expect(
        () => ControllerLayout(
          authoredSize: DefaultLayout.canvasSize,
          elements: {
            ...complete,
            'EXTRA': const ButtonElement(
              button: GamepadButton.A,
              rect: Rect.fromLTWH(0, 0, 44, 44),
            ),
          },
        ),
        throwsArgumentError,
      );
    });

    test('refuses a non-positive canvas', () {
      expect(
        () => ControllerLayout(
          authoredSize: Size.zero,
          elements: DefaultLayout.layout.elements,
        ),
        throwsArgumentError,
      );
    });

    test('is not modifiable through the elements map', () {
      expect(
        () => DefaultLayout.layout.elements['A'] = const ButtonElement(
          button: GamepadButton.B,
          rect: Rect.zero,
        ),
        throwsUnsupportedError,
      );
    });
  });
}
