INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

APPIMAGE_NAME="Gamypad-x86_64.AppImage" # Change this to your AppImage filename
APP_NAME="Gamypad"                      # The app name as it will appear in the menu

rm -rf $INSTALL_DIR/$APPIMAGE_NAME
rm -rf $DESKTOP_DIR/$APP_NAME.desktop

echo "Uninstalled Successfully"
echo "You can Delete everything inside this file now"
