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

info "🎮 Uninstalling Gamypad"

echo ""
info "[1/6] Removing installed files"
sudo rm -rf /opt/gamypad
sudo rm -f /usr/local/bin/gamypad
ok "Removed /opt/gamypad and /usr/local/bin/gamypad"

echo ""
info "[2/6] Removing desktop entry"
sudo rm -f /usr/share/applications/gamypad.desktop
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
ok "Removed desktop entry"

echo ""
info "[3/6] Removing udev rule"
sudo rm -f /etc/udev/rules.d/99-uinput.rules
ok "Removed /etc/udev/rules.d/99-uinput.rules"

echo ""
info "[4/6] Removing tmpfiles config"
sudo rm -f /etc/tmpfiles.d/uinput.conf
ok "Removed /etc/tmpfiles.d/uinput.conf"

echo ""
info "[5/6] Removing modules-load config"
sudo rm -f /etc/modules-load.d/uinput.conf
ok "Removed /etc/modules-load.d/uinput.conf"

echo ""
info "[6/6] Reloading udev"
sudo udevadm control --reload-rules
sudo udevadm trigger
ok "Reloaded udev rules"

echo ""
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "Gamypad uninstalled successfully!"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
warn "Optional: remove yourself from uinput group"
echo "  sudo gpasswd -d $USER uinput"
echo "  (input group membership is usually harmless to keep)"
echo ""
