#!/bin/bash

# ===== CONFIG =====
APPIMAGE_NAME="Gamypad-x86_64.AppImage" # Change this to your AppImage filename
APP_NAME="Gamypad"                      # The app name as it will appear in the menu
ICON_PATH="gamypad.png"                 # Path to icon (optional, can leave empty)
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
# ==================

# Check if AppImage exists
if [ ! -f "$APPIMAGE_NAME" ]; then
  echo "Error: $APPIMAGE_NAME not found in the current directory."
  exit 1
fi

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

# Move AppImage
cp "$APPIMAGE_NAME" "$INSTALL_DIR/"

# Make executable
chmod +x "$INSTALL_DIR/$APPIMAGE_NAME"

# Create .desktop file
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"
cat >"$DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=$APP_NAME
Exec=$INSTALL_DIR/$APPIMAGE_NAME
Icon=$ICON_PATH
Type=Application
Categories=Utility;Game;
EOL

# Make .desktop executable
chmod +x "$DESKTOP_FILE"

echo "$APP_NAME installed successfully!"
echo "You can now launch it from your application menu."
