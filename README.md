<div align="center">

# Gamypad

**Turn your Android phone into a wireless gamepad for Linux.**

Gamypad emulates an Xbox 360 controller via the Linux `uinput` subsystem — no drivers, no configuration. Just scan, connect, and play.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Linux](https://img.shields.io/badge/Linux-x86__64-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://kernel.org)
[![Android](https://img.shields.io/badge/Android-8.0+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

> **Beta** — APK and Linux binary available on the [Releases](https://github.com/abhijeetsagr-g/gamypad/releases) page.

</div>

---

## Screenshots

### Linux App

| Server Idle |  QR Code |
|-------------| --------|
| ![idle](screenshots/linux_idle.png) | ![qr](screenshots/linux_qr.png) |

### Android App

| Home | Controller |
|------|------------|
| ![home](screenshots/android_home.png) | ![controller](screenshots/android_controller.png) |

---

## ✨ What It Is

Gamypad is two pieces of software that work together:

- **Linux app** — runs a small UDP server on your PC and speaks directly to the
  kernel's `uinput` interface, so games see your phone as a real Xbox 360
  controller.
- **Android app** — connects to that server over WiFi and streams button
  presses, joystick, and trigger inputs in real time.

Both devices must be on the same network — a **phone hotspot** is recommended
for the most reliable, lowest-latency connection.

### Features

- Full Xbox 360 controller: A/B/X/Y, LB/RB, LT/RT, Start, Back, Guide, LS, RS
- Dual analog sticks with deadzone tuning and D-Pad
- Automatic pairing via QR code scan (manual IP entry also works)
- Resize and reposition every pad element with the built-in layout editor
- Optional haptic feedback and digital-trigger mode
- Connection watchdog — detects disconnects on both ends automatically

---

## Requirements

| | Requirement |
|---|---|
| Linux | x86_64 with `uinput` support, GTK 3 |
| Android | 8.0 (API 26) or newer |
| Network | Both devices on the same WiFi |

---

## Installation

### Linux

1. Download the latest release zip from the
   [Releases](https://github.com/abhijeetsagr-g/gamypad/releases) page.
2. Extract it and run the install script:

   ```bash
   unzip Gamypad-x86_64.zip
   chmod +x install.sh
   ./install.sh
   ```

3. **Log out and back in** so the `uinput` group changes take effect.

The script installs Gamypad to `/opt/gamypad`, adds a desktop entry, and sets up
the `uinput` udev rules automatically. You can then launch **Gamypad** from your
application menu or run `gamypad` from a terminal.

### Android

Download the APK from the [Releases](https://github.com/abhijeetsagr-g/gamypad/releases)
page and install it. You may need to allow "install from unknown sources" for
your browser or file manager.

---

## Usage

### First-time setup

1. Enable the **hotspot** on your Android phone.
2. Connect your PC to the phone's hotspot.

### Every session

1. Open **Gamypad** on your PC and click **Start Server** — a QR code with the
   connection address appears.
2. Open the **Gamypad** app on your phone and tap the **scan** button.
3. Point the camera at the QR code — the address fills in automatically.
   (Or type the address shown on the PC manually.)
4. Tap **Connect**. The status badge turns green when paired.
5. Tap **GAMEPAD** to open the controller, then play!

When you're done, hit the stop button on the PC or exit the controller — the
connection closes on both ends automatically.

---

## Uninstall

```bash
chmod +x uninstall.sh   # from the extracted release folder
./uninstall.sh
```

On the phone, uninstall the app like any other app.

---

## License

MIT

---

<div align="center">

Made with ❤️ and Flutter &nbsp;·&nbsp; [GitHub](https://github.com/abhijeetsagr-g/gamypad)

</div>