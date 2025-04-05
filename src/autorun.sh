#!/bin/bash

# Check if Cursor.AppImage exists
if [ ! -f "Cursor.AppImage" ]; then
    echo "Cursor.AppImage not found. Running download script..."
    ./download.sh
    
    # Check if download was successful
    if [ ! -f "Cursor.AppImage" ]; then
        echo "Error: Failed to download Cursor.AppImage."
        exit 1
    fi
    echo "Download completed successfully."
fi

echo "Cursor.AppImage is available."

# Run fix-header.sh to modify the AppImage
echo "Running fix-header.sh to modify the AppImage..."
./fix-header.sh

# Check if the script executed successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to run fix-header.sh."
    exit 1
fi
echo "AppImage modification completed successfully."

# Run create-desktop.sh to create desktop entry
echo "Running create-desktop.sh to create desktop entry..."
./create-desktop.sh

# Check if the script executed successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to run create-desktop.sh."
    exit 1
fi
echo "Desktop entry creation completed successfully."

# Clean up temporary files
echo "Cleaning up temporary files..."

# Remove Cursor.AppImage
if [ -f "Cursor.AppImage" ]; then
    echo "Removing Cursor.AppImage..."
    rm Cursor.AppImage
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to remove Cursor.AppImage."
    else
        echo "Cursor.AppImage removed successfully."
    fi
fi

# Remove squashfs-root directory
if [ -d "squashfs-root" ]; then
    echo "Removing squashfs-root directory..."
    rm -rf squashfs-root
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to remove squashfs-root directory."
    else
        echo "squashfs-root directory removed successfully."
    fi
fi

echo "Cleanup completed."

