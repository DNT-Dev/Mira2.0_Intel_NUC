#!/bin/bash

# Script to install udev rules for ROS devices

# Function to find a file in the current directory and its subdirectories
find_file() {
  find . -name "$1" -type f | head -n 1
}

# Define the destination path
DEST_DIR="/etc/udev/rules.d"

# Find the rule files
echo "Looking for udev rule files in the current directory and subdirectories..."
UVC_RULES=$(find_file "99-uvc.rules")
MIRA_RULES=$(find_file "96-mira.rules")

# Display the paths if found
if [ -n "$UVC_RULES" ]; then
  echo "Found 99-uvc.rules at: $UVC_RULES"
else
  echo "Could not find 99-uvc.rules automatically."
fi

if [ -n "$MIRA_RULES" ]; then
  echo "Found 96-mira.rules at: $MIRA_RULES"
else
  echo "Could not find 96-mira.rules automatically."
fi

# If files weren't found, ask for their paths
if [ -z "$UVC_RULES" ] || [ ! -f "$UVC_RULES" ]; then
  read -p "Please enter the full path to 99-uvc.rules: " UVC_RULES
  
  if [ ! -f "$UVC_RULES" ]; then
    echo "Error: File $UVC_RULES not found"
    exit 1
  fi
fi

if [ -z "$MIRA_RULES" ] || [ ! -f "$MIRA_RULES" ]; then
  read -p "Please enter the full path to 96-mira.rules: " MIRA_RULES
  
  if [ ! -f "$MIRA_RULES" ]; then
    echo "Error: File $MIRA_RULES not found"
    exit 1
  fi
fi

# Ensure the destination directory exists
sudo mkdir -p "$DEST_DIR"

# Copy the rules files to the destination
echo "Copying $UVC_RULES to $DEST_DIR (requires sudo)"
sudo cp "$UVC_RULES" "$DEST_DIR"

echo "Copying $MIRA_RULES to $DEST_DIR (requires sudo)"
sudo cp "$MIRA_RULES" "$DEST_DIR"

# Set the correct permissions
echo "Setting permissions on the rule files (requires sudo)"
sudo chmod 644 "$DEST_DIR/99-uvc.rules"
sudo chmod 644 "$DEST_DIR/96-mira.rules"

# Reload the udev rules
echo "Reloading udev rules (requires sudo)"
sudo udevadm control --reload-rules

# Trigger the rules to apply to existing devices
echo "Triggering udev rules (requires sudo)"
sudo udevadm trigger

echo "Installation complete!"
exit 0
