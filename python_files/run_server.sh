#!/bin/bash

# Exit on any error
set -e

# Set the name for the virtual environment directory
VENV_DIR="venv"

# Check if virtual environment already exists
if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment already exists at $VENV_DIR. Skipping creation and installation."
else
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"

    echo "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"

    echo "Upgrading pip..."
    pip install --upgrade pip

    echo "Installing vgamepad..."
    pip install vgamepad

    echo "vgamepad installed successfully in virtual environment: $VENV_DIR"
fi

# Activate the virtual environment (whether new or existing)
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Run the server
python scripts/server.py
