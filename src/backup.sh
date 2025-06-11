#!/bin/bash

# Source the version function and global variables
source ./version.sh
source ./globals.sh

# Function to check if backups exist
has_backups() {
    if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get list of backup versions
get_backup_versions() {
    if [ -d "$BACKUP_DIR" ]; then
        find "$BACKUP_DIR" -maxdepth 1 -type d -name "cursor_*" -printf "%f\n" 2>/dev/null | sed 's/^cursor_//'
    fi
}

# Function to create a backup of the current Cursor installation
create_backup() {
    local desktop_file="$DEST_DIR_DESKTOP/cursor.desktop"
    local url_handler_file="$DEST_DIR_DESKTOP/cursor-url-handler.desktop"
    local version=$(get_cursor_version "$desktop_file")
    
    if [ -z "$version" ]; then
        echo "Error: Could not determine Cursor version."
        return 1
    fi
    
    echo "Creating backup of Cursor version $version..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Check if Cursor is installed
    if [ -d "$DEST_DIR" ]; then
        # Remove existing backup of the same version if it exists
        if [ -d "$BACKUP_DIR/cursor_$version" ]; then
            echo "Overwriting existing backup for version $version..."
            rm -rf "$BACKUP_DIR/cursor_$version"
        fi
        
        # Create backup
        mkdir -p "$BACKUP_DIR/cursor_$version/cursor"
        cp -r "$DEST_DIR/"* "$BACKUP_DIR/cursor_$version/cursor/"
        
        # Backup desktop file if it exists
        if [ -f "$desktop_file" ]; then
            cp "$desktop_file" "$BACKUP_DIR/cursor_$version/"
        fi
        
        # Backup url handler file if it exists
        if [ -f "$url_handler_file" ]; then
            cp "$url_handler_file" "$BACKUP_DIR/cursor_$version/"
        fi
        
        echo "Backup created successfully for version $version"
        return 0
    else
        echo "No existing Cursor installation found to backup."
        return 1
    fi
}

# Function to restore a backup
restore_backup() {
    local specified_version="$1"
    
    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backups found. Nothing to restore."
        return 1
    fi
    
    # If version is specified, try to restore that specific version
    if [ -n "$specified_version" ]; then
        if [ ! -d "$BACKUP_DIR/cursor_$specified_version" ]; then
            echo "Backup for version $specified_version not found."
            return 1
        fi
        
        echo "Restoring backup for version $specified_version"
        
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
        
        # Remove current url handler file if it exists
        if [ -f "$DEST_DIR_DESKTOP/cursor-url-handler.desktop" ]; then
            echo "Removing current url handler file..."
            rm "$DEST_DIR_DESKTOP/cursor-url-handler.desktop"
        fi
        
        # Restore from backup
        echo "Restoring Cursor files..."
        cp -r "$BACKUP_DIR/cursor_$specified_version/cursor/"* "$DEST_DIR/"
        
        # Restore desktop file if it exists in the backup
        if [ -f "$BACKUP_DIR/cursor_$specified_version/cursor.desktop" ]; then
            echo "Restoring desktop file..."
            cp "$BACKUP_DIR/cursor_$specified_version/cursor.desktop" "$DEST_DIR_DESKTOP/"
        fi

        # Restore url handler file if it exists in the backup
        if [ -f "$BACKUP_DIR/cursor_$specified_version/cursor-url-handler.desktop" ]; then
            echo "Restoring url handler file..."
            cp "$BACKUP_DIR/cursor_$specified_version/cursor-url-handler.desktop" "$DEST_DIR_DESKTOP/"
        fi
        
        echo "Backup restored successfully for version $specified_version"
        return 0
    else
        # List all available backups
        echo "Available backups:"
        local backups=($(ls -d "$BACKUP_DIR"/cursor_* 2>/dev/null))
        
        if [ ${#backups[@]} -eq 0 ]; then
            echo "No backups found. Nothing to restore."
            return 1
        fi
        
        # Display backups with numbers
        for i in "${!backups[@]}"; do
            local version=$(basename "${backups[$i]}" | sed 's/cursor_//')
            echo "[$i] Version $version"
        done
        
        # Ask user to select a backup
        read -p "Enter the number of the backup to restore (or 'q' to quit): " selection
        
        # Check if user wants to quit
        if [[ "$selection" == "q" ]]; then
            echo "Restoration cancelled."
            return 0
        fi
        
        # Validate selection
        if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -ge ${#backups[@]} ]; then
            echo "Invalid selection. Restoration cancelled."
            return 1
        fi
        
        local version=$(basename "${backups[$selection]}" | sed 's/cursor_//')
        
        echo "Restoring backup for version $version"
        
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

        # Remove current url handler file if it exists
        if [ -f "$DEST_DIR_DESKTOP/cursor-url-handler.desktop" ]; then
            echo "Removing current url handler file..."
            rm "$DEST_DIR_DESKTOP/cursor-url-handler.desktop"
        fi

        # Restore from backup
        echo "Restoring Cursor files..."
        cp -r "${backups[$selection]}/cursor" "$DEST_DIR/"
        
        # Restore desktop file if it exists in the backup
        if [ -f "${backups[$selection]}/cursor.desktop" ]; then
            echo "Restoring desktop file..."
            cp "${backups[$selection]}/cursor.desktop" "$DEST_DIR_DESKTOP/"
        fi
        
        # Restore url handler file if it exists in the backup
        if [ -f "${backups[$selection]}/cursor-url-handler.desktop" ]; then
            echo "Restoring url handler file..."
            cp "${backups[$selection]}/cursor-url-handler.desktop" "$DEST_DIR_DESKTOP/"
        fi

        echo "Backup restored successfully for version $version"
        return 0
    fi
}