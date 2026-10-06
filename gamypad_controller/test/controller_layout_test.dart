import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gamypad_controller/src/layout/controller_layout.dart';
import 'package:gamypad_controller/src/layout/default_layout.dart';
import 'package:gamypad_controller/src/layout/pad_element.dart';
import 'package:protocol/protocol.dart';

void main() {
  // The editor offers reset only when the layout in hand differs from the
  // default, so `==` is load-bearing on a surface rather than incidental. Every
  // commit builds a new instance, which means an identity comparison would report
  // every layout as modified and pin the button open forever.

  group('value equality', () {
    test('a layout equals itself', () {
      expect(DefaultLayout.layout, DefaultLayout.layout);
    });

    test('a decoded layout equals the layout it was encoded from', () {
      final original = DefaultLayout.layout;

      expect(ControllerLayout.decode(original.encode()), original);
    });

    test('two independently built identical layouts are equal', () {
      final a = ControllerLayout(
        authoredSize: DefaultLayout.canvasSize,
        elements: DefaultLayout.layout.elements,
      );
      final b = ControllerLayout(
        authoredSize: DefaultLayout.canvasSize,
        elements: DefaultLayout.layout.elements,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a layout moved and put back equals the original', () {
      final original = DefaultLayout.layout;
      final guide = original['GUIDE']!;

      final there = original.place(
        'GUIDE',
        guide.rect.shift(const Offset(20, 0)),
      );
      expect(there, isNot(original), reason: 'the move has to register');

      expect(there.place('GUIDE', guide.rect), original);
    });

    test('equality survives an element being resized', () {
      final original = DefaultLayout.layout;
      final stick = original['leftStick']!;

      final grown = original.place(
        'leftStick',
        Rect.fromLTWH(
          stick.rect.left,
          stick.rect.top,
          stick.rect.width + 8,
          stick.rect.height + 8,
        ),
      );

      expect(grown, isNot(original));
      expect(grown.place('leftStick', stick.rect), original);
    });

    test('a different authored canvas is a different layout', () {
      // Same sixteen rects, different canvas: not the same layout, and the
      // difference has to survive so reset is still offered.
      final resized = ControllerLayout(
        authoredSize: const Size(900, 400),
        elements: DefaultLayout.layout.elements,
      );

      expect(resized, isNot(DefaultLayout.layout));
      expect(resized.elements.length, DefaultLayout.layout.elements.length);
    });

    test('a different element is a different layout', () {
      final original = DefaultLayout.layout;

      final other = ControllerLayout(
        authoredSize: DefaultLayout.canvasSize,
        elements: {
          ...original.elements,
          'A': const ButtonElement(
            button: GamepadButton.A,
            rect: Rect.fromLTWH(700, 240, 56, 56),
          ),
        },
      );

      expect(other, isNot(original));
    });

    test('is not fooled by a same-sized element in a different place', () {
      // Size alone would pass a naive comparison; only the rect matters.
      final original = DefaultLayout.layout;
      final a = original['A']!.rect;
      final b = original['B']!.rect;

      expect(a.size, b.size, reason: 'precondition: same size, different spot');

      final swapped = ControllerLayout(
        authoredSize: DefaultLayout.canvasSize,
        elements: {
          ...original.elements,
          'A': ButtonElement(button: GamepadButton.A, rect: b),
        },
      );

      expect(swapped, isNot(original));
    });

    test('an invalid layout can still be compared', () {
      // Equality must not depend on validity: an overlap the editor is showing
      // in the error colour is still a concrete arrangement to be compared with.
      final stacked = DefaultLayout.layout.place(
        'A',
        DefaultLayout.layout['LB']!.rect,
      );

      expect(stacked.isValid, isFalse);
      expect(
        stacked,
        DefaultLayout.layout.place('A', DefaultLayout.layout['LB']!.rect),
      );
      expect(stacked.hashCode, isNot(DefaultLayout.layout.hashCode));
    });

    test('refuses a slot whose element disagrees about its id', () {
      // The constructor rejects this, so two layouts can never differ by element
      // *type* alone — which is why equality only has to compare ids and rects.
      final original = DefaultLayout.layout;

      expect(
        () => ControllerLayout(
          authoredSize: DefaultLayout.canvasSize,
          elements: {
            ...original.elements,
            'LS': StickElement(
              stick: GamepadStick.leftStick,
              rect: original['LS']!.rect,
            ),
          },
        ),
        throwsArgumentError,
      );
    });
  });

  group('ordering independence', () {
    test('element order in the source map does not affect equality', () {
      final original = DefaultLayout.layout;
      final shuffled = {
        for (final id in PadElement.ids.reversed) id: original[id]!,
      };

      expect(
        ControllerLayout(
          authoredSize: DefaultLayout.canvasSize,
          elements: shuffled,
        ),
        original,
      );
    });
  });
}
