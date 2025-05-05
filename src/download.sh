#!/bin/bash

# Source global variables
source ./globals.sh

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed."
    read -p "Would you like to install curl? (y/n) " choice
    case "$choice" in 
        y|Y )
            if command -v apt &> /dev/null; then
                sudo apt install -y curl
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y curl
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm curl
            else
                echo "Could not determine package manager. Please install curl manually."
                exit 1
            fi
            ;;
        * )
            echo "curl is required for this script. Exiting."
            exit 1
            ;;
    esac
fi


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