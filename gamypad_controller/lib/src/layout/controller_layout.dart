import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'pad_element.dart';

/// Where every element sits, and the canvas those numbers were chosen against.
///
/// **Absolute px plus a uniform scale.** A layout is rendered at
/// `max(screenW / authoredW, screenH / authoredH)` and centred, which is the
/// only scheme where all sixteen elements keep their aspect ratios without a
/// per-type special case. Normalized fractions were the tidier-looking option
/// and were rejected: on any screen that is not the authored aspect ratio, a
/// stick stored as `0.2 × 0.2` renders `480 × 216` and the curve is wrong.
///
/// `max` covers the screen rather than fitting inside it, so elements near the
/// canvas edge fall outside on the short axis. Known and temporary — the canvas
/// is authored at a controller's 2:1 and is being reworked for a phone aspect,
/// which is where that overhang goes away. The alternative, distortion, is
/// never acceptable.
///
/// Invariant, and the thing that makes reset a safe fallback: every element is
/// inside the canvas and no two rects overlap. See [isValid].
final class ControllerLayout {
  /// Normalises the element map into [PadElement.ids] order and rejects any set
  /// that is not exactly the sixteen.
  factory ControllerLayout({
    required Size authoredSize,
    required Map<String, PadElement> elements,
  }) {
    if (authoredSize.width <= 0 || authoredSize.height <= 0) {
      throw ArgumentError.value(
        authoredSize,
        'authoredSize',
        'must be positive',
      );
    }

    final ordered = <String, PadElement>{};
    for (final id in PadElement.ids) {
      final element = elements[id];
      if (element == null) {
        throw ArgumentError.value(id, 'elements', 'layout is missing "$id"');
      }
      if (element.id != id) {
        throw ArgumentError.value(
          id,
          'elements',
          '"$id" was given as "${element.id}"',
        );
      }
      ordered[id] = element;
    }

    if (elements.length != PadElement.ids.length) {
      throw ArgumentError.value(
        elements.length,
        'elements',
        'expected exactly ${PadElement.ids.length} elements',
      );
    }

    return ControllerLayout._(authoredSize, Map.unmodifiable(ordered));
  }

  const ControllerLayout._(this.authoredSize, this.elements);

  /// Bumped when the JSON shape changes. [decode] refuses anything it does not
  /// recognise rather than guessing.
  static const int currentVersion = 1;

  /// The canvas this layout was authored against.
  final Size authoredSize;

  /// The sixteen elements by id, in [PadElement.ids] order. Unmodifiable.
  final Map<String, PadElement> elements;

  /// [elements] in paint order.
  List<PadElement> get ordered => elements.values.toList(growable: false);

  PadElement? operator [](String id) => elements[id];

  /// [id] at [rect], with its own size rules applied and the result kept inside
  /// the canvas.
  ///
  /// Deliberately does *not* reject overlaps: an editor drag needs to see the
  /// position it asked for while it is invalid, so rejection is [isValid] and
  /// the caller's decision.
  ControllerLayout place(String id, Rect rect) {
    final element = elements[id];
    if (element == null) {
      throw ArgumentError.value(id, 'id', 'no such pad element');
    }
    final placed = element.withRect(element.constrain(rect, authoredSize));
    if (placed == element) return this;

    return ControllerLayout._(
      authoredSize,
      Map.unmodifiable({...elements, id: placed}),
    );
  }

  /// The element whose rect contains [point], or null.
  ///
  /// Plain rectangle containment, and that is the whole point of forbidding
  /// overlaps: with no two rects intersecting there is no z-order to reason
  /// about, so `topmost wins` — which the PC's test pad does need — is not a
  /// case that has to exist.
  PadElement? elementAt(Offset point) {
    for (final element in ordered.reversed) {
      if (element.rect.contains(point)) return element;
    }
    return null;
  }

  /// Whether [rect] would land on top of any element other than [except].
  bool collides(Rect rect, {String? except}) =>
      elements.values.any((e) => e.id != except && e.rect.overlaps(rect));

  /// Every element inside the canvas.
  bool get isWithinCanvas => elements.values.every((e) => _contains(e.rect));

  bool _contains(Rect rect) =>
      rect.left >= 0 &&
      rect.top >= 0 &&
      rect.right <= authoredSize.width &&
      rect.bottom <= authoredSize.height;

  /// The invariant the editor maintains and the repository restores: inside the
  /// canvas, and no two elements overlapping.
  bool get isValid {
    if (!isWithinCanvas) return false;

    final seen = <Rect>[];
    for (final element in elements.values) {
      if (seen.any((other) => other.overlaps(element.rect))) return false;
      seen.add(element.rect);
    }
    return true;
  }

  /// Serialises to JSON.
  ///
  /// Iterates [PadElement.ids] rather than the map's own order, so a layout
  /// decoded from any source re-encodes to identical bytes.
  String encode() => jsonEncode({
    'version': currentVersion,
    'authoredWidth': authoredSize.width,
    'authoredHeight': authoredSize.height,
    'elements': [for (final id in PadElement.ids) _encoded(elements[id]!)],
  });

  Map<String, Object> _encoded(PadElement element) => {
    'id': element.id,
    'x': element.rect.left,
    'y': element.rect.top,
    'width': element.rect.width,
    'height': element.rect.height,
  };

  /// Rebuilds a layout from [encode]'s output.
  ///
  /// Geometry is put through each element's own [PadElement.constrain] on the
  /// way in, so hand-edited or truncated storage cannot produce a negative size
  /// or an element parked outside the canvas. Malformed input throws
  /// [FormatException]; callers that are restoring user data should fall back to
  /// `DefaultLayout` rather than propagate.
  static ControllerLayout decode(String source) {
    final json = jsonDecode(source);
    if (json is! Map) {
      throw FormatException('Layout must be an object, got: $json');
    }

    final version = json['version'];
    if (version != currentVersion) {
      throw FormatException(
        'Unsupported layout version: $version (this build reads '
        '$currentVersion)',
      );
    }

    final width = _number(json['authoredWidth'], 'authoredWidth');
    final height = _number(json['authoredHeight'], 'authoredHeight');
    if (width <= 0 || height <= 0) {
      throw FormatException(
        'Authored size must be positive, got: $width×$height',
      );
    }

    final entries = json['elements'];
    if (entries is! List) {
      throw FormatException('Layout "elements" must be a list, got: $entries');
    }

    final canvas = Size(width, height);
    final decoded = <String, PadElement>{};

    for (final entry in entries) {
      if (entry is! Map) {
        throw FormatException('Element must be an object, got: $entry');
      }
      final id = entry['id'];
      if (id is! String) {
        throw FormatException('Element "id" must be a string, got: $id');
      }
      if (decoded.containsKey(id)) {
        throw FormatException('Duplicate element "$id"');
      }

      final element = PadElement.fromId(
        id,
        Rect.fromLTWH(
          _number(entry['x'], '$id.x'),
          _number(entry['y'], '$id.y'),
          _number(entry['width'], '$id.width'),
          _number(entry['height'], '$id.height'),
        ),
      );
      decoded[id] = element.withRect(element.constrain(element.rect, canvas));
    }

    // Delegated to the constructor, so "missing", "unknown" and "wrong type"
    // all fail the same way whether the layout came from disk or from a caller.
    return ControllerLayout(authoredSize: canvas, elements: decoded);
  }

  /// Value equality, so a layout edited back to its starting shape compares
  /// equal to the original.
  ///
  /// Identity would be actively wrong here rather than merely blunt: every
  /// commit builds a fresh instance, so a caller asking "is this still the
  /// default?" would get `false` for a layout the user had not touched at all.
  /// The editor offers reset only when the answer is genuinely `true`, so that
  /// comparison has to be by value.
  ///
  /// Elements carry value equality of their own and the constructor normalises
  /// [elements] into [PadElement.ids] order, so comparing the maps is both
  /// order-independent and sufficient.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ControllerLayout &&
          other.authoredSize == authoredSize &&
          mapEquals(other.elements, elements);

  @override
  int get hashCode =>
      Object.hash(authoredSize, Object.hashAllUnordered(elements.values));

  @override
  String toString() =>
      'ControllerLayout(${authoredSize.width.toInt()}×'
      '${authoredSize.height.toInt()}, ${elements.length} elements'
      '${isValid ? '' : ', INVALID'})';
}

double _number(Object? raw, String field) {
  if (raw is num) {
    final value = raw.toDouble();
    if (value.isFinite) return value;
  }
  throw FormatException('"$field" must be a finite number, got: $raw');
}
