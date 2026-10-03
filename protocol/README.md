# protocol

The wire vocabulary shared by the two halves of [Gamypad](../).

- **`gamypad_controller`** (Android) — sends input
- **`gamypad_pc`** (Linux) — receives it and emulates an Xbox 360 pad via `uinput`

Both halves used to hand-write JSON and keep their own copy of the button
names. This package is the single source of truth for both, so they cannot
drift apart silently.

Pure Dart. No Flutter, no I/O — it describes the messages and nothing else, so
it stays usable from a plain `dart test`.

## Usage

Path dependency, as used by both apps:

```yaml
dependencies:
  protocol:
    path: ../protocol
```

### Sending

```dart
import 'package:protocol/protocol.dart';

// Buttons are state, not edges: 1 is down, 0 is up.
utf8.encode(
  const ButtonMessage(button: GamepadButton.A, pressed: true).encode(),
);

// Triggers are analog.
utf8.encode(
  const TriggerMessage(trigger: GamepadTrigger.LT, value: 255).encode(),
);

// Sticks carry both axes.
utf8.encode(
  const StickMessage(stick: GamepadStick.leftStick, x: 32767, y: -32767)
      .encode(),
);
```

### Receiving

```dart
final message = Message.fromJson(jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>);

switch (message) {
  case ButtonMessage(:final button, :final pressed):
    gamepad.setButton(button, pressed);
  case TriggerMessage(:final trigger, :final value):
    gamepad.setTrigger(trigger, value);
  case StickMessage(:final stick, :final x, :final y):
    gamepad.setStick(stick, x, y);
  case Ping():
    send(const Pong());
  case Pong():
    break;
}
```

Anything unrecognised throws a `FormatException` rather than being ignored, so
a malformed packet surfaces instead of silently doing nothing.

## The wire format

One JSON object per UDP datagram, UTF-8 encoded. Every message is two keys:
`action` names the input, `value` carries the payload.

Connection health uses a separate `type` key, which no input message may use:

```json
{"type":"ping"}
{"type":"pong"}
```

Input:

```json
{"action":"A","value":1}
{"action":"LT","value":255}
{"action":"leftStick","value":{"x":32767,"y":-32767}}
```

`value` is always a JSON number for buttons and triggers, and an object of two
numbers for sticks. Numeric strings are also accepted when decoding.

## Vocabulary

`GamepadButton` — the fifteen key names in `gamypad_pc/native/Gamepad.cpp`'s
`keyMap`:

| | | | |
|---|---|---|---|
| `A` | `B` | `X` | `Y` |
| `LB` | `RB` | `START` | `SELECT` |
| `LS` | `RS` | `GUIDE` | |

`GamepadTrigger` — `LT`, `RT`. These are analog and deliberately absent from
`GamepadButton`.

`GamepadStick` — `leftStick`, `rightStick`.

The constant names *are* the wire tokens, not Dart style. Renaming one is a
breaking protocol change.

### Ranges

| Constant | Value | Meaning |
|---|---|---|
| `triggerMin` / `triggerMax` | `0` / `255` | analog trigger travel, unsigned |
| `stickMin` / `stickMax` | `-32767` / `32767` | each stick axis, signed 16-bit |
| `stickCenter` | `0` | a centred stick |

`TriggerMessage.normalized` maps the trigger range onto `0.0..1.0`.
`StickMessage.xOffset` / `yOffset` map an axis onto `-1.0..1.0` about
`stickCenter`.

## Notes for anyone building a controller

**Send state, not events.** A message says "A is down", not "A was pressed".
Resending one is harmless, which is what makes UDP the right transport — a
lost packet is corrected by the next one rather than needing a retransmit.

**Coalesce state, never drop edges.** Stick and trigger updates arrive faster
than the network needs; send only the newest at a fixed rate. Buttons are
different — dropping one is a dropped input.

**The native `keyMap` must stay in step.** `gamypad_pc/test/keymap_parity_test.dart`
asserts that `keyMap` in `Gamepad.cpp` matches `GamepadButton` exactly, in order.
Editing one without the other breaks input with no error — a drifted name is a
`std::map::operator[]` insert of `BTN_0`, which does nothing and raises nothing.

## Signed sticks, unsigned triggers

Sticks and triggers deliberately use different ranges:

- **Sticks** are signed 16-bit (`-32767..32767`). This is what the Linux `xpad`
  driver reports for `ABS_X`/`ABS_Y`/`ABS_RX`/`ABS_RY`, and what
  `gamypad_pc/native/Gamepad.cpp` configures. Signed means centre is exactly
  `0` and `xOffset`/`yOffset` reach precisely `-1.0` and `1.0` with no
  asymmetry.
- **Triggers** are unsigned bytes (`0..255`), matching `ABS_Z`/`ABS_RZ`.

The asymmetry is in the hardware, so it is mirrored here rather than papered
over. Pinned by tests in `test/protocol_test.dart`.

## Tests

```sh
dart test
```