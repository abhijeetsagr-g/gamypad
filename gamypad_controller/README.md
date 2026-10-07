# gamypad_controller

The **Android** half of [Gamypad](../README.md) — turns a phone into a wireless
Xbox 360 controller.

Part of the Gamypad monorepo. See the [root README](../README.md) for
installation, usage, and how the two halves fit together.

## Layout

```
lib/
├── main.dart / app.dart         forces landscape + immersive fullscreen
└── src/
    ├── connection/
    │   ├── gamepad_transport.dart  GamepadTransport interface
    │   ├── udp_transport.dart      UDP socket, 3s ping, 5s watchdog
    │   ├── transport_provider.dart riverpod provider wiring the transport
    │   ├── connection_target.dart  host:port pair (QR payload / manual entry)
    │   └── connection_status.dart  idle / connecting / connected / ...
    ├── input/
    │   ├── gamepad_input.dart      press/release/sticks/triggers, re-sends held
    │   │                            state on reconnect, optional haptics
    │   ├── stick_curve.dart        analog stick scaling + deadzone
    │   └── trigger_curve.dart      trigger travel -> 0..255
    ├── layout/
    │   ├── pad_element.dart        one pad element (button/stick/trigger) by id
    │   ├── controller_layout.dart  data-driven layout: authored size + elements
    │   ├── default_layout.dart     the shipped preset
    │   └── layout_repository.dart  persist layout as one JSON string
    ├── settings/
    │   ├── setting_model.dart      vibrate, digitalTriggers
    │   └── setting_repository.dart persist settings via shared_preferences
    └── ui/
        ├── state/                  connection/input/layout/setting controllers
        ├── view/                   home, controller, editor, QR scan, settings
        └── widgets/                editor/*, home/*, pad/*, qr/*

docs/                      layout-editor-design.md — the editor's design spec
```

## What the app does

- **Pairing** — scan the QR code the PC shows (payload is `host:port`), or type
  the address manually. Connection status is displayed live and kept alive with
  pings; a watchdog drops a silent peer after a few seconds.
- **Controller** — the pad is *data*, not hardcoded widgets: every element is
  placed from `ControllerLayout`. The **editor** moves/resizes elements and
  saves the result to local storage; **reset** restores the default.
- **Settings** — optional haptic feedback on button press and a digital-trigger
  mode (triggers become full-press on/off instead of analog).

The whole connection + input layer is pure Dart and tested under a plain
`dart test` — no Flutter test harness.

## The wire contract

Button names come from the shared [`protocol`](../protocol) package
(`protocol/lib/src/vocabulary/buttons.dart`). They must stay in sync with
`../gamypad_pc/native/Gamepad.cpp` (`keyMap`). Renaming a wire token is a
breaking protocol change — keep the two `pubspec.yaml` versions in sync.

## Build

```bash
flutter pub get
flutter build apk --release
```

Requires Flutter 3.x+ and Android SDK. Minimum Android version is 8.0 (API 26),
set in `android/app/build.gradle.kts`.