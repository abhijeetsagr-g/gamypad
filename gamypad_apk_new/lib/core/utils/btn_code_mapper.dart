class BtnCodeMapper {
  // display name → wire code (must match C++ keyMap keys)
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

  static const Set<String> _triggers = {'LT', 'RT'};
  static const Set<String> _dpad = {'UP', 'DOWN', 'LEFT', 'RIGHT'};

  static String codeOf(String btnName) => _buttons[btnName] ?? btnName;
  static bool isTrigger(String btnCode) => _triggers.contains(btnCode);
  static bool isDpad(String btnCode) => _dpad.contains(btnCode);
}
