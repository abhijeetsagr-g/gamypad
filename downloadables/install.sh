#!/bin/bash
set -e

APP_NAME="gamypad"
APP_DIR="$HOME/.local/share/$APP_NAME"
BIN_PATH="$HOME/.local/bin/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"

echo "📦 Installing $APP_NAME for user $USER..."

# Ensure local bin + apps dirs exist
mkdir -p "$APP_DIR" "$HOME/.local/bin" "$HOME/.local/share/applications"

# Copy the whole bundle
cp -r linux/* "$APP_DIR/"

# Create/overwrite symlink to binary
ln -sf "$APP_DIR/gamypad_pc" "$BIN_PATH"
chmod +x "$APP_DIR/gamypad_pc"

# Install .desktop entry
tee "$DESKTOP_FILE" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Gamypad
Exec=$BIN_PATH
Icon=$APP_DIR/icon.png
Terminal=false
Categories=Game;
EOF

echo "✅ $APP_NAME installed for user $USER!"
