/// Maps a UI button name to the wire code the Linux side expects.
///
/// The values in [_buttons] are the shared contract with `native/Gamepad.cpp`
/// (`keyMap`) and `core/gamepad.dart` (the `action` dispatch). Changing a code
/// here without changing those breaks input on the PC.
class BtnCodeMapper {
  // display name -> wire code (must match C++ keyMap keys)
  static const Map<String, String> _buttons = {
    'A': 'A',
    'B': 'B',
    'X': 'X',
    'Y': 'Y',
    'LB': 'LB',
    'RB': 'RB',
    'LT': 'LT',
    'RT': 'RT',
    'START': 'START',
    'SELECT': 'SELECT',
    'LS': 'LS',
    'RS': 'RS',
    'GUIDE': 'GUIDE',
    'UP': 'UP',
    'DOWN': 'DOWN',
    'LEFT': 'LEFT',
    'RIGHT': 'RIGHT',
  };

  // Triggers travel as an axis (0..255) rather than a press/release pair.
  static const Set<String> _triggers = {'LT', 'RT'};

  static String codeOf(String btnName) => _buttons[btnName] ?? btnName;

  static bool isTrigger(String btnCode) => _triggers.contains(btnCode);
}
