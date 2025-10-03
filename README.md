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
Download The `Gamypad-Full.zip` for downloading both Gamypad app for Android and Linux. Or Just the `Gamypad_X86*.zip` for Only the Linux AppImage. 
Unzip The App and run `./install.sh` and it will show up on your app launcher.
You Can Later Use `./uninstall.sh` to delete the app launcher files.


### How To Run
- Connect your system and your android phone into the same network.

- Open The Application.
- Click on **Start Server** in the Linux application.
- Open the Android application, and connect to the server using the **IP address and port** displayed in the Linux app.
- You are good to go! 🎮


## TO DO
- [x] Write Installation Steps
- [ ] Add Sticky Dpad
