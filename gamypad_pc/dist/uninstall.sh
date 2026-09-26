#!/bin/bash
set -e

echo "🎮 Uninstalling Gamypad..."
echo ""

echo "[1/5] Removing binary and symlink..."
sudo rm -rf /opt/gamypad
sudo rm -f /usr/local/bin/gamypad

echo "[2/5] Removing udev rule..."
sudo rm -f /etc/udev/rules.d/99-uinput.rules
sudo rm -f /etc/tmpfiles.d/uinput.conf

echo "[3/5] Removing module autoload..."
sudo rm -f /etc/modules-load.d/uinput.conf

echo "[4/5] Removing desktop entry..."
sudo rm -f /usr/share/applications/gamypad.desktop
sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true

echo "[5/5] Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "✓ Gamypad uninstalled successfully!"
echo "⚠  You may want to remove yourself from the uinput group manually:"
echo "   sudo gpasswd -d $USER uinput"