import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'pad_element.dart';

final class ControllerLayout {
  factory ControllerLayout({
    required String name,
    required Size authoredSize,
    required Map<String, PadElement> elements,
    Set<String> hidden = const {},
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

    final known = PadElement.ids.toSet();
    for (final id in hidden) {
      if (!known.contains(id)) {
        throw ArgumentError.value(id, 'hidden', 'no such pad element');
      }
    }

    return ControllerLayout._(
      name: name,
      authoredSize: authoredSize,
      elements: Map.unmodifiable(ordered),
      hidden: Set.unmodifiable(hidden),
    );
  }

  const ControllerLayout._({
    required this.name,
    required this.authoredSize,
    required this.elements,
    required this.hidden,
  });

  /// Older layouts were saved without the "hidden" set; treating them as
  /// having nothing hidden keeps them loadable after an upgrade.
  static const int firstHiddenVersion = 2;

  static const int currentVersion = 2;

  final Size authoredSize;
  final String name;
  final Map<String, PadElement> elements;

  /// Element ids the user has hidden: not rendered and not touchable, and they
  /// don't block other elements or fail validity checks.
  final Set<String> hidden;

  List<PadElement> get ordered => elements.values.toList(growable: false);

  /// Everything that should render, i.e. the element ids not in [hidden].
  List<PadElement> get visible => [
    for (final element in ordered)
      if (!hidden.contains(element.id)) element,
  ];

  bool isHidden(String id) => hidden.contains(id);

  PadElement? operator [](String id) => elements[id];

  /// A copy of this layout with the hidden set replaced by [hidden].
  ControllerLayout withHidden(Set<String> hidden) => ControllerLayout(
    name: name,
    authoredSize: authoredSize,
    elements: elements,
    hidden: hidden,
  );

  ControllerLayout place(String id, Rect rect) {
    final element = elements[id];
    if (element == null) {
      throw ArgumentError.value(id, 'id', 'no such pad element');
    }
    final placed = element.withRect(element.constrain(rect, authoredSize));
    if (placed == element) return this;

    return ControllerLayout(
      name: name,
      authoredSize: authoredSize,
      elements: Map.unmodifiable({...elements, id: placed}),
      hidden: hidden,
    );
  }

  /// A copy of this layout stored under [name], for saving it as a preset.
  ControllerLayout withName(String name) => ControllerLayout._(
    name: name,
    authoredSize: authoredSize,
    elements: elements,
    hidden: hidden,
  );

  /// The element whose rect contains [point], or null.
  PadElement? elementAt(Offset point) {
    for (final element in ordered.reversed) {
      if (element.rect.contains(point)) return element;
    }
    return null;
  }

  bool collides(Rect rect, {String? except}) => visible.any(
    (e) => e.id != except && e.rect.overlaps(rect),
  );

  bool get isWithinCanvas =>
      visible.every((e) => _contains(e.rect));

  bool _contains(Rect rect) =>
      rect.left >= 0 &&
      rect.top >= 0 &&
      rect.right <= authoredSize.width &&
      rect.bottom <= authoredSize.height;

  bool get isValid {
    if (!isWithinCanvas) return false;

    final seen = <Rect>[];
    for (final element in visible) {
      if (seen.any((other) => other.overlaps(element.rect))) return false;
      seen.add(element.rect);
    }
    return true;
  }

  /// Serialises to JSON.
  String encode() => jsonEncode({
    'name': name,
    'version': currentVersion,
    'authoredWidth': authoredSize.width,
    'authoredHeight': authoredSize.height,
    'hidden': (hidden.toList()..sort()),
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
    if (version != 1 && version != currentVersion) {
      throw FormatException(
        'Unsupported layout version: $version (this build reads 1 or '
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

    final Object? name = json['name'];
    if (name is! String) {
      throw FormatException('Name must be a string, got: $name');
    }

    final hidden = <String>[];
    if (version >= firstHiddenVersion) {
      final rawHidden = json['hidden'];
      if (rawHidden != null) {
        if (rawHidden is! List) {
          throw FormatException('Layout "hidden" must be a list, got: $rawHidden');
        }
        for (final id in rawHidden) {
          if (id is! String) {
            throw FormatException('Hidden id must be a string, got: $id');
          }
          if (!PadElement.ids.contains(id)) {
            throw FormatException('Unknown hidden element "$id"');
          }
          if (!hidden.contains(id)) hidden.add(id);
        }
      }
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

    return ControllerLayout(
      authoredSize: canvas,
      elements: decoded,
      name: name,
      hidden: Set.unmodifiable(hidden),
    );
  }

  /// Value equality, so a layout edited back to its starting shape compares
  /// equal to the original.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ControllerLayout &&
          other.authoredSize == authoredSize &&
          other.name == name &&
          mapEquals(other.elements, elements) &&
          setEquals(other.hidden, hidden);

  @override
  int get hashCode => Object.hash(
    authoredSize,
    Object.hashAllUnordered(elements.values),
    Object.hashAllUnordered(hidden),
  );

  @override
  String toString() =>
      'ControllerLayout(${authoredSize.width.toInt()}×'
      '${authoredSize.height.toInt()}, ${elements.length} elements'
      '${hidden.isEmpty ? '' : ', ${hidden.length} hidden'}'
      '${isValid ? '' : ', INVALID'})';
}

double _number(Object? raw, String field) {
  if (raw is num) {
    final value = raw.toDouble();
    if (value.isFinite) return value;
  }
  throw FormatException('"$field" must be a finite number, got: $raw');
}
