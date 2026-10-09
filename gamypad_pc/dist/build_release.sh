#!/usr/bin/env bash
# Assembles Gamypad-<version>-x86_64.zip for distribution.
# Extracting the zip creates a single top-level directory containing everything.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
DIST="$ROOT/dist"
BUNDLE_SRC="$ROOT/build/linux/x64/release/bundle"

# Extract version from pubspec.yaml (e.g. 1.3.0+1 -> 1.3.0)
VERSION="$(grep -m1 '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d+ -f1)"
NAME="Gamypad-${VERSION}-x86_64"
STAGE="$DIST/$NAME"
ZIP="$DIST/${NAME}.zip"

echo "==> Building Flutter Linux release (v$VERSION)"
flutter build linux --release

echo "==> Preparing staging directory: $NAME"
rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

echo "==> Copying release bundle to $NAME/Gamypad"
cp -r "$BUNDLE_SRC" "$STAGE/Gamypad"

echo "==> Validating required files"
REQUIRED=(
  "Gamypad/gamypad_pc"
  "Gamypad/lib/libapp.so"
  "Gamypad/lib/libflutter_linux_gtk.so"
  "Gamypad/lib/libgamepad.so"
  "Gamypad/data/flutter_assets/assets/icon.png"
)
for req in "${REQUIRED[@]}"; do
  if [[ ! -e "$STAGE/$req" ]]; then
    echo "!! Missing: $req" >&2
    echo "   Check pubspec.yaml assets include assets/icon.png" >&2
    exit 1
  fi
done

echo "==> Generating .desktop entry"
cat > "$STAGE/gamypad.desktop" <<'EOF'
[Desktop Entry]
Name=Gamypad
Comment=Use your smartphone as a wireless gamepad on Linux
Exec=/opt/gamypad/gamypad_pc
Icon=/opt/gamypad/data/flutter_assets/assets/icon.png
Type=Application
Categories=Game;Utility;
Terminal=false
EOF

echo "==> Copying install/uninstall scripts"
cp "$DIST/install.sh" "$STAGE/install.sh"
cp "$DIST/uninstall.sh" "$STAGE/uninstall.sh"
chmod +x "$STAGE/install.sh" "$STAGE/uninstall.sh"

echo "==> Creating archive: $(basename "$ZIP")"
rm -f "$ZIP"
(cd "$DIST" && zip -qr "$(basename "$ZIP")" "$NAME")

echo ""
echo "✓ $ZIP"
ls -lh "$ZIP"
echo ""
echo "Extract with: unzip $(basename "$ZIP")"
echo "Then run:   cd $NAME && ./install.sh"
