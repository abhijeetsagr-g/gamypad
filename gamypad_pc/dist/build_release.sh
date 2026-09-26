#!/bin/bash
# Assembles the distributable Gamypad-x86_64.zip.
#
# This replaces the old approach of committing a prebuilt `Gamypad/` bundle to
# the repository (which was ~50MB of dead weight in git history). The bundle is
# now a build product: it is generated here and uploaded to GitHub Releases.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
BUNDLE="$ROOT/dist/Gamypad"
VERSION="$(grep -m1 '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d+ -f1)"
ZIP="$ROOT/dist/Gamypad-x86_64.zip"

echo "==> Building Flutter Linux release (v$VERSION)"
flutter build linux --release

echo "==> Copying bundle to dist/Gamypad"
rm -rf "$BUNDLE"
cp -r "$ROOT/build/linux/x64/release/bundle" "$BUNDLE"

# Ship only what the user needs. Anything missing here breaks install.sh.
for required in gamypad_pc lib/libapp.so lib/libflutter_linux_gtk.so lib/libgamepad.so \
                data/flutter_assets/assets/icon.png; do
  if [[ ! -e "$BUNDLE/$required" ]]; then
    echo "!! Missing from bundle: $required" >&2
    echo "   (check that assets/icon.png is declared in pubspec.yaml)" >&2
    exit 1
  fi
done

echo "==> Zipping"
rm -f "$ZIP"
(cd "$ROOT/dist" && zip -qr "$(basename "$ZIP")" Gamypad install.sh uninstall.sh)

echo ""
echo "✓ $ZIP"
ls -lh "$ZIP"
echo ""
echo "Next: upload it to the GitHub Release for tag v$VERSION alongside the APK."
