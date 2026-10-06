import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'pad_element.dart';

final class ControllerLayout {
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

  static const int currentVersion = 1;

  final Size authoredSize;
  final Map<String, PadElement> elements;

  List<PadElement> get ordered => elements.values.toList(growable: false);
  PadElement? operator [](String id) => elements[id];

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
  PadElement? elementAt(Offset point) {
    for (final element in ordered.reversed) {
      if (element.rect.contains(point)) return element;
    }
    return null;
  }

  bool collides(Rect rect, {String? except}) =>
      elements.values.any((e) => e.id != except && e.rect.overlaps(rect));

  bool get isWithinCanvas => elements.values.every((e) => _contains(e.rect));

  bool _contains(Rect rect) =>
      rect.left >= 0 &&
      rect.top >= 0 &&
      rect.right <= authoredSize.width &&
      rect.bottom <= authoredSize.height;

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

    return ControllerLayout(authoredSize: canvas, elements: decoded);
  }

  /// Value equality, so a layout edited back to its starting shape compares
  /// equal to the original.
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
