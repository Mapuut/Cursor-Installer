#!/bin/bash

# Define the destination directory
DEST_DIR="$HOME/.local/share/applications/cursor"

# Check if squashfs-root directory exists
if [ ! -d "squashfs-root" ]; then
    echo "Error: squashfs-root directory not found!"
    exit 1
fi


# Check if the destination directory exists
if [ -d "$DEST_DIR" ]; then
    echo "Directory $DEST_DIR already exists. Removing it..."
    rm -rf "$DEST_DIR"
fi

# Create the destination directory
echo "Creating directory $DEST_DIR..."
mkdir -p "$DEST_DIR"

# Move the contents of squashfs-root to the destination directory
echo "Moving squashfs-root contents to $DEST_DIR..."
cp -r squashfs-root/* "$DEST_DIR/"

# Copy the desktop file to applications directory
echo "Copying cursor.desktop to applications directory..."
if [ -f "$HOME/.local/share/applications/cursor.desktop" ]; then
    echo "Desktop file already exists. Replacing it..."
    rm "$HOME/.local/share/applications/cursor.desktop"
fi
# Read the desktop file from res folder, replace $HOME with actual home path, and write to applications directory
sed "s|\$HOME|$HOME|g" "../res/cursor.desktop" > "$HOME/.local/share/applications/cursor.desktop"

echo "Installation complete. Cursor is now available in your applications menu. You might need to wait a second for it to show up."
