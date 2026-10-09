#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

info()  { echo -e "${BOLD}$*${RESET}"; }
ok()    { echo -e "${GREEN}✓${RESET} $*"; }
warn()  { echo -e "${YELLOW}⚠${RESET} $*"; }
err()   { echo -e "${RED}✗${RESET} $*"; }

info "🎮 Installing Gamypad"

echo ""
info "[1/8] Checking dependencies"
for lib in libgtk-3.so.0 libglib-2.0.so.0; do
  if ldconfig -p | grep -q "$lib"; then
    ok "Found $lib"
  else
    err "Missing $lib — install gtk3 (e.g. pacman -S gtk3)"
    exit 1
  fi
done

echo ""
info "[2/8] Creating uinput group"
if getent group uinput >/dev/null 2>&1; then
  ok "uinput group already exists"
else
  sudo groupadd uinput
  ok "Created uinput group"
fi

echo ""
info "[3/8] Adding $USER to uinput and input groups"
sudo usermod -aG uinput,input "$USER"
ok "Added $USER to uinput,input"

echo ""
info "[4/8] Preparing /dev/uinput permissions"
if [[ -e /dev/uinput ]]; then
  sudo chown root:uinput /dev/uinput
  sudo chmod 0660 /dev/uinput
  ok "Set permissions on /dev/uinput"
else
  warn "/dev/uinput does not exist yet"
  echo "  It will be created by the uinput kernel module on next boot/load."
fi

echo ""
info "[5/8] Installing udev, tmpfiles and module autoload"
echo 'KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="uinput", MODE="0660", TAG+="uaccess"' \
  | sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null
ok "Wrote /etc/udev/rules.d/99-uinput.rules"

echo 'c /dev/uinput 0660 root uinput -' \
  | sudo tee /etc/tmpfiles.d/uinput.conf >/dev/null
ok "Wrote /etc/tmpfiles.d/uinput.conf"

echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
ok "Wrote /etc/modules-load.d/uinput.conf"

echo ""
info "[6/8] Loading uinput module & applying udev"
if command -v modinfo >/dev/null 2>&1; then
  modinfo uinput >/dev/null 2>&1 && ok "uinput module is available" || warn "uinput module not found via modinfo"
fi
if lsmod | grep -q '^uinput'; then
  ok "uinput already loaded"
else
  sudo modprobe uinput 2>/dev/null && ok "Loaded uinput" || warn "Could not modprobe uinput now (will load on reboot)"
fi
sudo udevadm control --reload-rules
sudo udevadm trigger
ok "Reloaded udev rules"

echo ""
info "[7/8] Installing Gamypad to /opt/gamypad"
if [[ ! -d ./Gamypad ]]; then
  err "./Gamypad/ not found in current directory"
  echo "  Make sure you're inside the extracted Gamypad-*-x86_64 folder."
  exit 1
fi
sudo rm -rf /opt/gamypad
sudo cp -r ./Gamypad /opt/gamypad
sudo chmod +x /opt/gamypad/gamypad_pc
sudo ln -sf /opt/gamypad/gamypad_pc /usr/local/bin/gamypad
ok "Copied to /opt/gamypad and symlinked to /usr/local/bin/gamypad"

echo ""
info "[8/8] Installing desktop entry"
if [[ -f ./gamypad.desktop ]]; then
  sudo install -Dm644 ./gamypad.desktop /usr/share/applications/gamypad.desktop
  ok "Installed gamypad.desktop from archive"
else
  warn "gamypad.desktop not found in archive, creating one now"
  DESKTOP_FILE="$(mktemp)"
  cat > "$DESKTOP_FILE" <<'EOF'
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
  ok "Created /usr/share/applications/gamypad.desktop"
fi
sudo chmod 644 /usr/share/applications/gamypad.desktop
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
ok "Updated desktop database"

echo ""
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Gamypad installed successfully!"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
warn "Log out and back in for group changes to take effect."
echo "  Alternatives: 'newgrp uinput' in this shell, or 'su - $USER'"
echo ""
echo "Launch: gamypad  (or from your Applications menu)"
echo ""
