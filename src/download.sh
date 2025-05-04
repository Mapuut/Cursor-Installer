#!/bin/bash

# Source global variables
source ./globals.sh

# Using grep and sed instead of jq
APPIMAGE_URL=$( curl -s 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest' | grep -o '"downloadUrl":"[^"]*"' | sed 's/"downloadUrl":"//;s/"$//' )

# Create tmp directory if it doesn't exist
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"

# Download the file to tmp folder
echo "Downloading Cursor AppImage..."
wget -O ../tmp/Cursor.AppImage $APPIMAGE_URL

# Make it executable
chmod +x ../tmp/Cursor.AppImage

echo "Cursor.AppImage downloaded successfully."