# Controller view + controller editor — design

Status: **agreed, not started.** This is the spec to code from in a fresh session.

Scope: the landscape controller surface, and an editor for arranging it. Both are
new work in `gamypad_controller/lib/src/`. The PC half is untouched.

---

## 1. Why this exists

Today's pad is structure, not data. `gamypad_pc`'s test widgets are the closest
reference for the current look, and every one of them hardcodes its geometry:

- `test_dpad.dart` — `_w = 120.0`, `_h = 40.0`, `SizedBox(width: 40)`
- `test_face_buttons.dart` — `_w = 100.0`, `_h = 60.0`, `SizedBox(width: 60)`
- `test_top_bar.dart` — `LT 160`, `LB 140`, `GUIDE 120`, `RB 140`, `RT 160`
- `test_center_buttons.dart` — `100 × 40` each

The pivot: **geometry moves out of the widget tree into a model.** `TopBar`,
`FaceButtons` and `CenterButtons` stop being widgets and become default
positions in a preset. Every element is then placed by a rect, and resizing is a
data change rather than a layout change.

Follows the same seam the repo already draws: pure Dart for anything with no
Flutter in it (`lib/src/input/stick_curve.dart`, `lib/src/connection/*`), widgets
on top (`lib/src/ui/`).

## 2. Decisions

Settled with the user. This table is the spec.

| Question | Answer | Consequence |
|---|---|---|
| Presets | One layout + reset | `ControllerLayout` is a record, not a map keyed by name |
| LT / RT | Movable, **not** resizable | Size comes from constants; travel derives from the fixed height |
| Offline use | Editor always available; play shows a banner | Play is never blocked, never silent |
| Sticks | Locked square | One handle; `StickCurve.max` follows rendered size |
| Storage | `shared_preferences` | One new dependency, one JSON string |
| Button resize | Free, via a corner handle | Width and height move independently |
| Overlap | **Prevented** | No z-order needed anywhere |
| Triggers | Linear travel + small deadzone | Finger position is the pressure |
| D-pad | Square, like a stick | One size value drives arm thickness and gap |
| Grid snap | None | Diagonal drags stay straight |
| Editor orientation | Landscape, locked | Layout cannot be authored in the wrong shape |
| Hiding | All 16 elements always present | No "missing" state in the model |

## 3. The sixteen elements

Addressable elements, and the ids used in storage.

| Id | Kind | Notes |
|---|---|---|
| `A` `B` `X` `Y` | button | Face diamond, individually placed |
| `LB` `RB` | button | Shoulders |
| `START` `SELECT` | button | Centre row |
| `LS` `RS` | button | Centre row |
| `GUIDE` | button | Centre row |
| `dpad` | dpad | Owns `UP` `DOWN` `LEFT` `RIGHT` as one group |
| `LT` `RT` | trigger | Fixed size, movable along the top |
| `leftStick` `rightStick` | stick | One design, two instances |

Ids are the `protocol` enum names, plus the literal `dpad` for the group. Stable
across a change to any on-screen *label*, which is all persistence needs.

The D-pad needs its own id because it owns four `GamepadButton`s and the PC
combines them into one hat: `UinputDevice.setButton` keeps `_up`/`_down`/`_left`/
`_right` and recomputes a single `gamepadSetDpad(x, y)`. Holding UP and RIGHT
must produce a diagonal, so the four are independent buttons inside one
resizable box.

## 4. Model

Per-type classes rather than one record with nullable fields — the constraints
genuinely differ per type, and declaring them on the type keeps the editor from
switching on kind at every call site.

```dart
sealed class PadElement {
  String get id;
  Rect get rect;
  bool get movable;
  bool get resizable;
  MinMax get minSize;
  MinMax get maxSize;      // null = unbounded
}

final class ButtonElement extends PadElement {   // the 11 singles
  final GamepadButton button;
  // free resize: independent width and height
}

final class DpadElement extends PadElement {     // square, non-nullable
  // size drives arm thickness and the centre gap
}

final class StickElement extends PadElement {    // square, one handle
  final GamepadStick stick;
}

final class TriggerElement extends PadElement {  // resizable == false
  final GamepadTrigger trigger;
}
```

Each type owns its constraints, so adding a fifth kind is a compile-time
decision rather than a silent fallthrough.

`ControllerLayout`:

- the 16 elements, addressable by id
- `authoredSize` — the canvas they were laid out against (§5)
- `version` for JSON
- `encode()` / `decode()`, both pure

`LayoutRepository` — an interface plus the `shared_preferences` implementation.
Kept behind an interface so persistence can change without the views noticing,
and so tests can use an in-memory one.

`DefaultLayout` — today's pad as authored constants, and the target of reset.

**No hiding.** All 16 always exist. A "missing" concept would have to be carried
through rendering, hit testing and persistence for a feature nobody asked for.

## 5. Coordinate system

**Absolute px, plus the canvas size the layout was authored against, rendered
with a single uniform scale:**

```
scale = max(screenW / authoredW, screenH / authoredH)
```

then centred.

Normalized `0..1` fractions look tidier and were rejected: on any screen that is
not the authored aspect ratio, a stick stored as `0.2 × 0.2` renders `480 × 216`
and the curve is wrong. A uniform scale is the only scheme where all 16 elements
keep their aspect ratios with no per-type special case.

`max` covers the screen instead of fitting inside it. `min` was the original
choice and it letterboxed a visible band down each side of every phone, since the
800×400 canvas is 2:1 and a phone in landscape is closer to 2.2:1 — roughly 10%
of the width went unused. Covering is preferred over that gap.

The cost is that elements at the canvas edge can fall outside the screen, which
the play surface hides (it draws no canvas outline) but the editor shows.
Accepted as temporary: the default layout is authored against desktop controller
proportions and is to be repositioned for a phone aspect, which removes the
overhang at the source. Distortion remains never acceptable.

## 6. Overlap prevention

Prevented, and the prevention is forgiving:

1. The element follows the finger freely while dragging.
2. While it would collide, its outline draws in the error colour.
3. On release it **reverts to the last valid position**.

Snapping back mid-drag feels broken; reverting on release never leaves a bad
layout behind.

A useful consequence: since no two rects can intersect, hit testing is plain
rectangle containment with **no z-order**. `Topmost wins` — which the PC's test
pad needs for overlapping sticks — is not a case that has to exist here.

Clamp to screen bounds on the same terms.

## 7. The two surfaces, one renderer

`PadRenderer` turns a layout into widgets. Both surfaces use it, and it is the
only path from layout to pixels — so what gets arranged is exactly what gets
played, and no widget can drift between the two.

| | Play surface | Editor surface |
|---|---|---|
| Wrapper | gestures wired to `GamepadInput` | drag + corner resize |
| Appearance | identical | identical |
| Banner | shown when not connected | none needed |

Widgets never learn which mode they are in. That keeps them testable and keeps
the mode switch in exactly one place.

### Play surface

Landscape, locked. Buttons report through `GamepadInput.press`/`release`, sticks
through `setStick`, triggers through `setTrigger`.

When not connected: a banner, and presses visibly do nothing. Never blocked,
never silent. `ConnectionStatusBadge` already distinguishes `disconnected` from
`lost` — the editor and play surfaces should use the same vocabulary.

### Editor surface

Landscape, locked. Tap to select, drag to move, corner handle to resize. A reset
action returns to `DefaultLayout`.

## 8. Triggers

**Slide to press. More travel, more pressure.**

Linear travel with a small deadzone, so the pressure on screen is the pressure on
the wire. Finger position is the truth on a phone — note that the PC's
`AnalogTrigger` ramps over a fixed `Duration` instead, which is right for a mouse
and wrong for a thumb.

- Fixed size, movable along the top. **Not** resizable, so travel never changes.
- Travel is derived from the rendered height; nothing stores it.
- Needs `lib/src/input/trigger_curve.dart`, shaped like `StickCurve`: a pure
  function, no widget, no Flutter import.
- Direction is **up for more** — intuitive in landscape. Flag this at
  implementation time if it feels wrong on a device; it is a one-line change.

## 9. Traps in the existing code

Not hypothetical — each of these breaks quietly under a resizable layout.

1. **`StickCurve.max` defaults to `130.0` and is caller-supplied.** The old
   joystick normalised by its own `_maxDis`, so resizing a stick currently
   changes the distance the thumb must travel to reach full deflection — a
   cosmetic resize would alter the feel. `max` must be **derived from the
   rendered size**, never stored.
2. **D-pad internals are hardcoded** — `120 × 40` arms and a fixed
   `SizedBox(width: 40)` gap. Both must derive from the group's size, or the
   cross distorts as it grows.
3. **If A/B/X/Y become freely placeable, the user can build an unusable
   controller.** Guardrails: clamp to screen, prevent overlap, one-tap reset.
4. **`GamepadInput.releaseAll()` exists and is not optional.** Any path that ends
   the play session — back button, disconnect, lock screen — must release held
   buttons and centre the sticks, or the PC keeps them stuck. The watchdog and
   `UinputDevice.dispose` both handle the PC side; the phone side is this call.

## 10. Files

```
lib/src/layout/
  pad_element.dart           sealed hierarchy, per-type constraints, ids
  controller_layout.dart     the 16 elements, JSON encode/decode, versioned
  layout_repository.dart     interface + shared_preferences impl
  default_layout.dart        today's pad as constants

lib/src/input/
  trigger_curve.dart         travel -> triggerMin..triggerMax, linear + deadzone

lib/src/ui/view/
  controller_view.dart       landscape, play
  controller_editor_view.dart landscape, edit

lib/src/ui/widgets/pad/
  pad_palette.dart           colours; matches HomePalette / GamepadTestPalette
  pad_renderer.dart          layout -> widgets, the one shared path
  stick.dart                 square-locked, one design for both instances
  dpad.dart                  square, arm thickness + gap from one size
  button.dart                the 11 singles, free resize
  trigger.dart               slide to press

lib/src/ui/widgets/editor/
  selection_overlay.dart     handles, invalid-state outline
  editor_gestures.dart       drag, corner resize, overlap rejection
```

`pubspec.yaml` gains one dependency: `shared_preferences`.

Colours reuse `HomePalette.background` (`0xFF0D0D0D`), `accent`
(`0xFF00FF88`), and the surface/border set from `GamepadTestPalette`, so all
three surfaces read as one product. That duplication is deliberate — the three
are separate features, and a shared theme is a later concern.

## 11. Suggested order

1. **Model and curves** — `pad_element.dart`, `controller_layout.dart`,
   `default_layout.dart`, `trigger_curve.dart`. Pure Dart, no Flutter, so
   checkable under a plain `dart test`.
2. **The six pad widgets** — over protocol types, no transport knowledge. Shapes
   scale from their size from the first commit.
3. **`pad_renderer.dart`** — one layout to widgets.
4. **The two surfaces** — play, then editor gestures and overlay.
5. **Persistence** — `layout_repository.dart`, and the `shared_preferences` bump.

Order 1 before 2 deliberately: the widgets are unwriteable until the size
constraints have somewhere to live.

## 12. Out of scope

Agreed, unless raised:

- Multiple named presets (one layout + reset only)
- Hiding elements
- Undo / redo — reset covers the mistake case, undo would cover exploration
- A live "test while editing" mode
- Per-element opacity
- Sharing or exporting a layout between devices

## 13. Tests

The existing suite stays pure: `lib/src/connection/` and `lib/src/input/` run
under `dart test` with no Flutter harness, and the model and curves belong to
that group.

Worth covering when this is built:

- `default_layout.dart` — every id present exactly once, no two rects overlapping,
  every size inside its type's constraints. This is a real invariant, not a
  formality: it is what makes reset a safe fallback.
- `controller_layout.dart` — round-trip through `encode`/`decode`, and a
  layout authored at an unusual size surviving it.
- `trigger_curve.dart` — rest reads `triggerMin`, full travel reads
  `triggerMax`, both monotonic.
- `stick_curve.dart` already covered; add the case that `max` derived from
  rendered size keeps full deflection at the edge of any size.

Widget tests were deliberately skipped for the play surface during the connect
work, at the user's request, in favour of testing on a real device. Same call
applies here unless that changes.