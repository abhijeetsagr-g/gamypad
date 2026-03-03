# Gamypad

> Turn your Android phone into a wireless gamepad for Linux.

Gamypad lets you use your smartphone as a fully functional game controller on Linux. It emulates an Xbox 360 controller via the Linux `uinput` subsystem, so it works with any game that supports a gamepad — no additional drivers or configuration required.

---

## How It Works

Gamypad has two components:

- **Linux app** — runs a UDP server that receives input from your phone and emulates an Xbox 360 controller
- **Android app** — connects to the server over WiFi and sends button presses, joystick movements, and trigger inputs

Communication is over UDP for low-latency input. The phone and PC must be on the same network — a **phone hotspot** is recommended for the most reliable connection.

---

## Features

- Emulates an Xbox 360 controller via `uinput`
- Full button support — A, B, X, Y, LB, RB, LT, RT, Start, Back, Guide, LS, RS
- Dual joysticks and D-Pad
- Automatic server detection via QR code scan
- Connection watchdog — detects when server or client disconnects
- Wireless input via UDP over WiFi

---

## Requirements

- Linux (x86_64)
- Android phone (Android 8.0+)
- Both devices on the same WiFi network (phone hotspot recommended)

---

## Installation

### Linux

1. Download the latest release zip from the [Releases](https://github.com/abhijeetsagr-g/gamypad/releases) page
2. Extract the zip:
    
    ```bash
    unzip Gamypad-x86_64.zip
    ```
    
3. Run the install script:
    
    ```bash
    chmod +x install.sh./install.sh
    ```
    
4. Log out and back in for group permission changes to take effect

### Android

Download and install the APK from the [Releases](https://github.com/abhijeetsagr-g/gamypad/releases) page.

---

## Usage

1. Enable hotspot on your Android phone
2. Connect your PC to the phone's hotspot
3. Open **Gamypad** on your PC and click **Start Server**
4. Open the Android app, tap the QR scanner icon, and scan the QR code shown on the PC
5. Tap **Connect** — you're ready to play

---

## Uninstallation

```bash
chmod +x uninstall.sh
./uninstall.sh
```

---

## Building from Source

### Prerequisites

- Flutter SDK
- CMake
- Clang
- GTK3 development headers

```bash
sudo pacman -S cmake clang gtk3  # Arch
sudo apt install cmake clang libgtk-3-dev  # Ubuntu/Debian
```

### Linux app

```bash
cd gamypad_pc
flutter pub get
flutter build linux --release
```

### Android app

```bash
cd gamypad_apk
flutter pub get
flutter build apk --release
```

---

## License

MIT