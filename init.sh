#!/bin/bash
echo "You have to do this just once, hopefully"

echo "[1/6] Checking & loading uinput module..."
if ! lsmod | grep -q uinput; then
    sudo modprobe uinput && echo "✅ uinput module loaded."
else
    echo "✅ uinput already loaded."
fi

echo "[2/6] Ensuring uinput loads on boot..."
echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf > /dev/null

echo "[3/6] Adding your user ($USER) to input group..."
sudo gpasswd -a "$USER" input

echo "[4/6] Creating persistent udev rule..."
UDEV_RULE="/etc/udev/rules.d/99-uinput.rules"
if [ ! -f "$UDEV_RULE" ]; then
    echo 'KERNEL=="uinput", MODE="0660", GROUP="input"' | sudo tee "$UDEV_RULE" > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "✅ udev rule created."
else
    echo "✅ udev rule already exists."
fi

echo "[5/6] Creating Python virtual environment..."
python3 -m venv python/venv
echo "✅ Virtual environment created at python/venv"

echo "[6/6] Activating venv, installing vgamepad, and exiting venv..."

VENV_PATH="python/venv" # Define the path to the virtual environment

echo "Upgrading pip within the virtual environment..."
"$VENV_PATH/bin/python3" -m pip install --upgrade pip
if [ $? -eq 0 ]; then
    echo "✅ pip upgraded successfully."
else
    echo "❌ Failed to upgrade pip."
fi

echo "Installing vgamepad within the virtual environment..."
"$VENV_PATH/bin/python3" -m pip install vgamepad
if [ $? -eq 0 ]; then
    echo "✅ vgamepad installed successfully."
else
    echo "❌ Failed to install vgamepad."
fi

# No need for 'deactivate' here as we didn't truly activate the environment for the script's subsequent commands
# The virtual environment is now set up and ready to be activated manually by the user or by the run_server.sh script.

echo
echo "✅ All done!"
echo "➡️  Log out & log back in (or reboot) for uinput changes to take effect."
echo "➡️  Run, run the ./run_server.sh"
