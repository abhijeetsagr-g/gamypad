📱 Use Your Phone as a Game Controller!

Control your PC games using your Android phone — wirelessly!

This project features:

🎮 Flutter-based mobile app for a customizable gamepad UI

🌐 Socket.IO communication between Android and Python server

🖥️ Python server on Arch Linux (or any Linux/Windows) that translates inputs to virtual gamepad signals using vgamepad

Status: 🚧 Work in ProgressContributions are welcome! Feel free to open issues or submit pull requests 🙌

🧠 How It Works

The Flutter app captures button inputs on your phone.

These inputs are sent over the network via Socket.IO in JSON format.

A Python server receives this data and translates it into gamepad signals using vgamepad.

Your PC interprets it just like a real game controller — perfect for games!

📷 Preview

![photo_2025-07-04_14-29-38](https://github.com/user-attachments/assets/abae74d9-4562-4723-a7b4-3bedbd2f9f19)


🚀 Getting Started

Setup guide and instructions coming soon!Until then, feel free to explore the code and start tinkering.

🛠️ Tech Stack

Frontend: Flutter (Android)

Backend: Python 3, socket.io, vgamepad

OS Support:✅ Arch Linux (tested)✅ Should work on other Linux distros and Windows

🤝 Contribute

This project is open to contributions! Whether it’s improving UI, adding new control schemes, or porting it to iOS — you're welcome to help!
