# gamypad_controller

The **Android** half of [Gamypad](../README.md) — turns a phone into a wireless
Xbox 360 controller.

Part of the Gamypad monorepo. See the [root README](../README.md) for the
protocol, installation, and how the two halves fit together.

## Layout

```
lib/
├── core/utils/          btn_code_mapper.dart — button name -> wire code
│                        show_snackbar.dart
├── logic/
│   ├── services/        client_service.dart — UDP socket, ping/pong, watchdog
│   └── riverpod/        client_state.dart, client_notifier.dart, providers.dart
└── ui/
    ├── connect/         view/ + widget/ — pair with the PC over QR or manual IP
    └── gamepad/         view/ + widget/ — the landscape controller surface
```

## The wire contract

`btn_code_mapper.dart` holds the button codes. They must stay in sync with
`../gamypad_pc/native/Gamepad.cpp` (`keyMap`) and
`../gamypad_pc/core/gamepad.dart` (the `action` dispatch). A rename on one side
without the other silently breaks that input on the PC.

## Build

```bash
flutter pub get
flutter build apk --release
```

Requires Flutter 3.x+ and Android SDK. Minimum Android version is 8.0 (API 26),
set in `android/app/build.gradle.kts`.
