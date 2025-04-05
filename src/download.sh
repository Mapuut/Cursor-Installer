#!/bin/bash

# Using grep and sed instead of jq
APPIMAGE_URL=$( curl -s 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest' | grep -o '"downloadUrl":"[^"]*"' | sed 's/"downloadUrl":"//;s/"$//' )

# Download the file
echo "Downloading Cursor AppImage..."
wget -O Cursor.AppImage $APPIMAGE_URL

# Make it executable
chmod +x Cursor.AppImage

echo "Download complete. Cursor.AppImage is ready to use."