#!/bin/bash

# Source the version function and global variables
source ./version.sh
source ./globals.sh

# Function to create a temporary backup
create_temporary_backup() {
    # Check if desktop file exists before trying to get version
    local backup_version=""
    if [ -f "$DEST_DIR_DESKTOP/cursor.desktop" ]; then
        backup_version=$(get_cursor_version "$DEST_DIR_DESKTOP/cursor.desktop" || echo "")
    fi
    
    if [ -n "$backup_version" ]; then
        echo "Existing Cursor installation found ($backup_version)."
        
        # Create temporary backup directory
        if [ -d "$TEMP_BACKUP_DIR" ]; then
            rm -rf "$TEMP_BACKUP_DIR"
        fi
        mkdir -p "$TEMP_BACKUP_DIR"
        
        # Create backup of current installation
        cp -r "$DEST_DIR" "$TEMP_BACKUP_DIR/"
        if [ -f "$DEST_DIR_DESKTOP/cursor.desktop" ]; then
            cp "$DEST_DIR_DESKTOP/cursor.desktop" "$TEMP_BACKUP_DIR/"
        fi
        
        echo "Temporary backup created successfully."
        return 0
    else
        echo "No existing Cursor installation found. No temporary backup needed."
        return 1
    fi
}

# Function to restore from temporary backup
restore_temporary_backup() {
    # Get version from temporary backup
    local backup_version=""
    if [ -f "$TEMP_BACKUP_DIR/cursor.desktop" ]; then
        backup_version=$(get_cursor_version "$TEMP_BACKUP_DIR/cursor.desktop" || echo "")
    fi
    
    if [ -n "$backup_version" ]; then
        echo "Restoring from temporary backup version $backup_version..."
        
        # Remove current installation if it exists
        if [ -d "$DEST_DIR" ]; then
            echo "Removing current Cursor installation..."
            rm -rf "$DEST_DIR"
        fi
        
        # Remove current desktop file if it exists
        if [ -f "$DEST_DIR_DESKTOP/cursor.desktop" ]; then
            echo "Removing current desktop file..."
            rm "$DEST_DIR_DESKTOP/cursor.desktop"
        fi
        
        # Restore from temporary backup
        echo "Restoring Cursor files..."
        cp -r "$TEMP_BACKUP_DIR/cursor" "$DEST_DIR/"
        
        # Restore desktop file if it exists in the backup
        if [ -f "$TEMP_BACKUP_DIR/cursor.desktop" ]; then
            echo "Restoring desktop file..."
            cp "$TEMP_BACKUP_DIR/cursor.desktop" "$DEST_DIR_DESKTOP/"
        fi
        
        echo "Successfully restored from temporary backup version $backup_version."
        return 0
    else
        echo "No temporary backup found to restore from."
        return 1
    fi
}

# Function to clean up temporary backup
cleanup_temporary_backup() {
    if [ -d "$TEMP_BACKUP_DIR" ]; then
        echo "Cleaning up temporary backup..."
        rm -rf "$TEMP_BACKUP_DIR"
        return 0
    else
        echo "No temporary backup found to clean up."
        return 1
    fi
}
