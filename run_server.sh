#!/bin/bash

echo "Starting server..."

# Define paths
VENV_PATH="python/venv"
SERVER_SCRIPT_PATH="python/server.py"

# --- 1. Check if the virtual environment directory exists ---
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Error: Virtual environment not found at '$VENV_PATH'."
    echo "Please run the setup script first to create the virtual environment."
    exit 1
fi

# Define the Python executable within the virtual environment
VENV_PYTHON="$VENV_PATH/bin/python3"

# --- 2. Check if vgamepad is installed in the virtual environment ---
echo "Checking for 'vgamepad' in the virtual environment..."

# We'll try to import vgamepad using the venv's python.
# If it fails, the import will return a non-zero exit code.
"$VENV_PYTHON" -c "import vgamepad" &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Error: 'vgamepad' not found or not importable in the virtual environment."
    echo "Please ensure 'vgamepad' is installed in '$VENV_PATH'."
    echo "You might need to run the setup script again or manually install it:"
    echo "  $VENV_PYTHON -m pip install vgamepad"
    exit 1
else
    echo "✅ 'vgamepad' found in the virtual environment."
fi

# --- 3. Check if the server script exists ---
if [ ! -f "$SERVER_SCRIPT_PATH" ]; then
    echo "❌ Error: Server script not found at '$SERVER_SCRIPT_PATH'."
    echo "Please ensure 'server.py' exists in the 'python/' directory."
    exit 1
fi

# --- 4. Run the server script using the virtual environment's Python ---
echo "🚀 Running server script: '$SERVER_SCRIPT_PATH' using '$VENV_PYTHON'..."
echo "------------------------------------------------------------------"

# Execute the server script
"$VENV_PYTHON" "$SERVER_SCRIPT_PATH"

# Add a message for when the server process exits
echo "------------------------------------------------------------------"
echo "Server process exited."
