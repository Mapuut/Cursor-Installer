#!/bin/bash

# Source global variables
source ./globals.sh

# Check if squashfs-root directory exists
if [ ! -d "$TEMP_DIR_EXTRACTED" ]; then
    echo "Error: $TEMP_DIR_EXTRACTED directory not found!"
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

# Source the version function
source ./version.sh

# Get the version from the desktop file
VERSION=$(get_cursor_version "$TEMP_DIR_EXTRACTED/cursor.desktop")
if [ -z "$VERSION" ]; then
    echo "Warning: Could not determine Cursor version."
    VERSION="unknown"
fi

# Remove cursor.desktop from TEMP_DIR_EXTRACTED if it exists
# if [ -f "$TEMP_DIR_EXTRACTED/cursor.desktop" ]; then
#     echo "Removing cursor.desktop from temporary directory..."
#     rm "$TEMP_DIR_EXTRACTED/cursor.desktop"
# fi

# Move the contents of squashfs-root to the destination directory
echo "Moving $TEMP_DIR_EXTRACTED contents to $DEST_DIR..."
cp -r "$TEMP_DIR_EXTRACTED"/* "$DEST_DIR/"

# Copy the desktop file to applications directory
echo "Copying cursor.desktop to applications directory..."
if [ -f "$HOME/.local/share/applications/cursor.desktop" ]; then
    echo "Desktop file already exists. Replacing it..."
    rm "$HOME/.local/share/applications/cursor.desktop"
fi

# Read the desktop file from res folder, replace $HOME with actual home path, and write to applications directory
sed -e "s|\$DEST_DIR|$DEST_DIR|g" -e "s|\$VERSION|$VERSION|g" "../res/cursor.desktop" > "$DEST_DIR_DESKTOP/cursor.desktop"

# Copy the url handler desktop file to applications directory
echo "Copying cursor-url-handler.desktop to applications directory..."
if [ -f "$HOME/.local/share/applications/cursor-url-handler.desktop" ]; then
    echo "Desktop file already exists. Replacing it..."
    rm "$HOME/.local/share/applications/cursor-url-handler.desktop"
fi

sed -e "s|\$DEST_DIR|$DEST_DIR|g" "../res/cursor-url-handler.desktop" > "$DEST_DIR_DESKTOP/cursor-url-handler.desktop"

echo "Installation complete. Cursor is now available in your applications menu. You might need to wait a second for it to show up."
