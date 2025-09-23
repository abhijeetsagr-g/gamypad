# Gamypad
> Use your smartphone as a virtual game controller on Linux inspired by PC REMOTE MONET.

---

**Gamypad** is a cross-platform solution that transforms your smartphone into a fully functional gamepad controller for Linux. 

---
## Features

- Emulates a Linux game controller
- Wireless input via socket connection
- On-screen joystick + buttons

## Prerequisites
Before installing, make sure your user is in the **`input`** group.  

To check, run 
```bash
groups
```
If it shows **`input`** , you are good to go. 

If not, run the following
```bash
sudo usermod -aG input $USER
```


## Installation
To download the application for android and your Linux system at once. Download `gamypad-full.zip` from release.

```bash
unzip gamypad-full.zip
cd gamypad-full/
```

You can either use an  adb connection to install the app to your phone or download `Gamypad.apk` from release tab. 

To use adb connection

- Enable USB Debugging on your Android Device
	- Go to **Settings → About phone → Tap "Build number" 7 times** to enable Developer Options.
	- Then go to **Settings → Developer options → USB Debugging** and enable it.

- Connect your phone via USB and verify the connection:
```bash 
adb devices
```

- Install the application
```bash
adb install Gamypad.apk
```

- Once installed, you can run the app on your phone. If you update the APK later, use:
```bash
adb install -r Gamypad.apk
```

### How To Run
- Connect your system and your android phone into the same network.

- Run the linux application,
``` bash
cd linux/
./gamypad
```

- Click on **Start Server** in the Linux application.
- Open the Android application, and connect to the server using the **IP address and port** displayed in the Linux app.
- You are good to go! 🎮


## TO DO
- [x] Write Installation Steps
- [ ] Add Sticky Dpad
