#!/bin/bash

# Exit on any error
set -e

# Step 1: Set the name for the virtual environment directory
VENV_DIR="venv"

echo "Creating virtual environment in $VENV_DIR..."
python3 -m venv "$VENV_DIR"

# Step 2: Activate the virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 3: Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Step 4: Install vgamepad
echo "Installing vgamepad..."
pip install vgamepad

echo "vgamepad installed successfully in virtual environment: $VENV_DIR"

python scripts/server.py
