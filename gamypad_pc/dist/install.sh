#!/bin/bash
set -e

echo "🎮 Installing Gamypad..."
echo ""

echo "Checking dependencies..."
for lib in libgtk-3.so.0 libglib-2.0.so.0; do
  if ! ldconfig -p | grep -q "$lib"; then
    echo "✗ Missing: $lib — install gtk3"
    exit 1
  fi
done
echo "✓ Dependencies OK"

# uinput setup
echo "[1/7] Creating uinput group..."
sudo groupadd -f uinput

echo "[2/7] Adding $USER to uinput and input groups..."
sudo usermod -aG uinput,input "$USER"

echo "[3/7] Setting /dev/uinput permissions..."
if [[ -e /dev/uinput ]]; then
  sudo chown root:uinput /dev/uinput
  sudo chmod 0660 /dev/uinput
else
  echo "   /dev/uinput not present yet — the uinput module will create it on reboot."
fi

echo "[4/7] Creating udev rule..."
echo 'KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="uinput", MODE="0660", TAG+="uaccess"' \
  | sudo tee /etc/udev/rules.d/99-uinput.rules > /dev/null
echo 'c /dev/uinput 0660 root uinput -' \
  | sudo tee /etc/tmpfiles.d/uinput.conf > /dev/null

echo "[5/7] Loading uinput module..."
echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf > /dev/null
if ! lsmod | grep -q '^uinput'; then
  sudo modprobe uinput || echo "   could not load uinput now; it will load on reboot."
fi
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "[6/7] Copying files to /opt/gamypad..."
if [[ ! -d ./Gamypad ]]; then
  echo "✗ ./Gamypad not found — unzip the release archive before running this script." >&2
  exit 1
fi
sudo rm -rf /opt/gamypad
sudo cp -r ./Gamypad /opt/gamypad
sudo ln -sf /opt/gamypad/gamypad_pc /usr/local/bin/gamypad

echo "[7/7] Creating desktop entry..."
DESKTOP_FILE="$(mktemp)"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Gamypad
Comment=Use your smartphone as a wireless gamepad on Linux
Exec=/opt/gamypad/gamypad_pc
Icon=/opt/gamypad/data/flutter_assets/assets/icon.png
Type=Application
Categories=Game;Utility;
Terminal=false
EOF
sudo cp "$DESKTOP_FILE" /usr/share/applications/gamypad.desktop
rm -f "$DESKTOP_FILE"
sudo chmod +x /opt/gamypad/gamypad_pc
sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true

echo ""
echo "✓ Gamypad installed successfully!"
echo "⚠  Log out and back in for group changes to take effect."
echo "   Then run: gamypad"