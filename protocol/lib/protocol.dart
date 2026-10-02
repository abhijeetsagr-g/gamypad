/// The shared wire vocabulary spoken by Gamypad's two applications.
///
/// `gamypad_controller` (Android) and `gamypad_pc` (Linux) talk over UDP using
/// the button names declared here. This package is the single source of truth
/// for that vocabulary, so the two halves cannot drift apart silently.
///
/// This package contains no I/O and no Flutter, so it stays usable from a plain
/// Dart test and from either application.
///
/// # Relationship to the native layer
///
/// The button names below are the *left-hand column* of the `keyMap` in
/// `gamypad_pc/native/Gamepad.cpp`. The *right-hand column* is made of Linux
/// kernel constants (`BTN_A`, `ABS_Z`, …) and cannot live in Dart. Keeping the
/// two in agreement is enforced by a parity test in `gamypad_pc/test/`.
///
/// LT and RT are deliberately absent from the button vocabulary: they travel as
/// analog axes rather than key presses, and have their own type.
library;

export 'src/messages.dart';
export 'src/vocabulary/buttons.dart';
