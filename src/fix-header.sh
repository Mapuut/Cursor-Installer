#!/bin/bash

# Step 1: Extract the AppImage
cd ../tmp && ./Cursor.AppImage --appimage-extract && cd ../src

# Step 2: Define the path to the target file
TARGET_FILE="../tmp/squashfs-root/usr/share/cursor/resources/app/out/main.js"


# Step 3: Replace all occurrences of ",minHeight" with ",frame:false,minHeight"
sed -i 's/,minHeight/,frame:false,minHeight/g' "$TARGET_FILE"


# Wouldn't recommend this step, but you can try
# Step 4: Repackage the AppImage using appimagetool
# ./appimagetool-x86_64.AppImage squashfs-root/