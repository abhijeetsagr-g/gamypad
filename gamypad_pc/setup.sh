#!/bin/bash

echo "Setting up uinput permissions for Gamypad..."

# Create uinput group if it doesn't exist
sudo groupadd -f uinput

# Add current user to uinput and input groups
sudo usermod -aG uinput,input $USER

# Set correct permissions on /dev/uinput
sudo chown root:uinput /dev/uinput
sudo chmod 0660 /dev/uinput

# Create permanent udev rule
echo 'KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="uinput", MODE="0660"' | sudo tee /etc/udev/rules.d/99-uinput.rules

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "Done! Please log out and log back in for changes to take effect."