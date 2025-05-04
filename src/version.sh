#!/bin/bash

# Function to get Cursor version from desktop file
get_cursor_version() {
    local desktop_file="$1"
    
    # Check if the desktop file exists
    if [ -f "$desktop_file" ]; then
        # Extract version using grep and pattern matching
        local version=$(grep -oP 'X-AppImage-Version=\K[0-9.]+' "$desktop_file")
        echo "$version"
    else
        echo "Error: Could not find desktop file at $desktop_file"
        return 1
    fi
}