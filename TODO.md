# Gamypad TODO

## Layout/Editor Enhancements

### Multi-layout support (per game/profile)

- [x] Extend `LayoutRepository` to support multiple named presets (store map of name -> layout JSON)
- [x] Add active layout selection (persist which preset is active) — stored under `controller_layout.active`
- [x] Add `saveAs(name)`, `load(name)`, `delete(name)`, `list()` methods to repository/controller
- [ ] Add UI to manage/switch between layouts (dropdown/list in editor or home)
- [ ] Consider metadata for presets (name, createdAt, lastModified)
- [x] Handle migration from current single-layout storage

### Editor improvements

- [ ] Add `editable`/`disabled` flag to `PadElement` to allow locking specific buttons from being moved/resized
- [ ] Allow hiding/disabling specific elements in editor without removing them from model
- [ ] Add visual indication for non-editable elements
- [ ] Grid/snapping options (optional - currently none)
- [ ] Undo/redo support for layout edits
- [ ] Element properties panel (fine-tune position/size)

### Layout features

- [ ] Layout per app/game detection (associate presets with game IDs)
- [ ] Import/export layouts as JSON files
- [ ] Copy/paste layout between presets
- [ ] Layout validation improvements (better error messages)

## Bugs / Polish

- [x] **Digital triggers stuck on press** — with `digitalTriggers` on, the
  trigger stayed held forever after lifting the finger. `PadTrigger` was fine
  (sends `triggerMax` on touch, `triggerMin` on finger-up); the bug was in
  `GamepadInput.setTrigger`, which rewrote *every* value to `triggerMax` in
  digital mode — including the `0` release. Fixed by only forcing full press
  while pressed (`value > triggerMin`), so release passes through. Bonus: the
  haptic now fires on press only, not on release. **Verify on device**: tap LT/RT
  quickly — they must release immediately.
- [x] **Stick diagonals didn't reach max** — right/left saturated at 32767 but
  diagonals topped out at 50% (16383). Cause: thumb travels a circle while each
  axis was read independently and gamma-shaped (`gamma: 2.0`), so 45° gave
  `0.707² = 0.5` per axis. Fixed in `StickCurve.apply()` by mapping the unit
  direction onto the square edge (`÷ max(|ux|, |uy|)`) before applying travel +
  gamma — straight drags unchanged, diagonals now hit `(32767, 32767)`.
  **Verify on device**: drag in circles, all angles should saturate equally.
  Note: `controller_view.dart` now has an unused `app_theme.dart` import
  (fallout from removing `backgroundColor`) — drop it if not mid-edit.
- [ ] **Stick direction distortion from per-axis gamma** — recorded 505 wire
  samples (`tools/record_sticks.py`, run with sudo) while spinning the stick:
  magnitudes are excellent (output hugs the ideal square within 0.6%, corners
  hit `(32767, 32767)` — diagonal fix confirmed), but the *output angle* deviates
  from the finger angle by **avg 8.3° = 18.3% of octant (worst ±12.8°)**. Square
  mapping itself is direction-preserving (scalar division); all distortion comes
  from `_shape()` squaring each axis independently — `atan(tan²θ)` pulls output
  toward the cardinals. Uniform-angle model predicts 18.5%, matching a reported
  "~21.4% avg error". Note: that spin sat at travel=1 the whole time, so gamma's
  magnitude effect (partial deflection) was **not** exercised. Proposed fix:
  apply gamma radially once (`travel^gamma`) instead of per axis → direction
  error 0%, response curve unchanged. Decide: radial gamma vs lower gamma
  (1.5 → 11.2%).
- [x] **Layout misalignment: editor vs controller view** — positions placed in the
  editor don't land in the same spot on the controller pad. Suspected cause:
  the editor rendered the canvas outside `SafeArea` while the controller view
  renders inside it, so system insets change the available bounds (and thus the
  `max(scale)` cover-fit and centering) differently per view. `SafeArea` was added
  to `controller_editor_view.dart` — **verify on a real device** (landscape +
  portrait, cutout/no-cutout). Second check if it persists: round-trip a rect
  through `encode()`/`decode()` to rule out persistence.

- [ ] DPad Don't Work As Intended in some games. Try Using Dpad with Gamepad Buttons
