import 'dart:io';

import 'package:protocol/protocol.dart';
import 'package:test/test.dart';

/// Guards the one thing that cannot be checked by the Dart compiler: the
/// agreement between `GamepadButton` in the protocol package and the `keyMap`
/// in the native uinput implementation.
///
/// `UinputDevice` passes `button.name` straight through as a C string and the
/// native side looks it up in `std::map<std::string, int> keyMap`. If a name
/// drifts, `operator[]` silently inserts `BTN_0` and the button does nothing.
/// Nothing in either build fails — it is a runtime no-op with no error, so it
/// has to be pinned by a test.
///
/// Reads the source as text, so it needs no compiler, no root and no
/// /dev/uinput.
void main() {
  final cpp = File('native/Gamepad.cpp').readAsStringSync();

  // Matches entries of the keyMap initialiser: {"A", BTN_A},
  final nativeButtons = RegExp(r'\{"(\w+)",\s*BTN_\w+\}')
      .allMatches(cpp)
      .map((match) => match.group(1)!)
      .toList();

  test('the native file was actually parsed', () {
    // If the regex ever stops matching, the tests below would pass vacuously.
    expect(nativeButtons, isNotEmpty);
  });

  test('every GamepadButton has a native key', () {
    expect(
      nativeButtons,
      containsAll(GamepadButton.values.map((button) => button.name)),
    );
  });

  test('the native keyMap matches GamepadButton in order', () {
    // Order matters: it pins .index-based lookups if the native side ever
    // moves from string keys to an array.
    expect(nativeButtons, GamepadButton.values.map((b) => b.name).toList());
  });

  test('the native keyMap has no extra entries', () {
    // Catches a key left behind in C++ after being removed from the protocol.
    expect(
      nativeButtons.toSet().difference(
        GamepadButton.values.map((button) => button.name).toSet(),
      ),
      isEmpty,
    );
  });
}
