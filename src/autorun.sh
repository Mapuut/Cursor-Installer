#!/bin/bash

# Function to check if running as sudo/root
check_not_sudo() {
    if [ "$EUID" -eq 0 ]; then
        echo "Error: This script should not be run as root/sudo."
        echo "Please run without sudo."
        exit 1
    fi
}

# Check sudo status before proceeding
check_not_sudo

# Source global variables
source ./globals.sh

# Source the version function
source ./version.sh

# Source backup script for backup checking functions
source ./backup.sh

# Remove tmp directory if it exists and create a fresh one
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi
mkdir -p "$TEMP_DIR"

# Function to prepare Cursor.AppImage
prepare_appimage() {
    # Check if user provided Cursor.AppImage in project root
    if [ -f "$PROJECT_ROOT/Cursor.AppImage" ]; then
        echo "User-provided Cursor.AppImage found. Copying to tmp folder..."
        cp "$PROJECT_ROOT/Cursor.AppImage" "$TEMP_DIR/Cursor.AppImage"
        chmod +x "$TEMP_DIR/Cursor.AppImage"
        return 0
    fi

    # If not found, run download script
    echo "No user-provided Cursor.AppImage found. Running download script..."
    ./download.sh
    
    # Check if download was successful
    if [ ! -f "$TEMP_DIR/Cursor.AppImage" ]; then
        echo "Error: Failed to download Cursor.AppImage."
        return 1
    fi
    
    return 0
}

# Function to install/update Cursor
install_update() {
    # Prepare Cursor.AppImage
    if ! prepare_appimage; then
        return 1
    fi

    # Now Cursor.AppImage is available in tmp folder.

    # Run fix-header.sh to modify the AppImage
    echo "Running fix-header.sh to modify the AppImage..."
    ./fix-header.sh

    # Check if the script executed successfully
    if [ $? -ne 0 ]; then
        echo "Error: Failed to run fix-header.sh."
        return 1
    fi
    echo "AppImage modification completed successfully."

    # Get version from extracted desktop file
    local desktop_file="$TEMP_DIR_EXTRACTED/cursor.desktop"
    local version=$(get_cursor_version "$desktop_file")
    if [ -z "$version" ]; then
        echo "Error: Could not determine Cursor version."
        return 1
    fi

    # Create temporary backup if needed
    source ./backup-temporary.sh
    create_temporary_backup

    # Check if Cursor is installed and ask about backup
    local installed_version=$(get_cursor_version "$DEST_DIR_DESKTOP/cursor.desktop" || echo "")
    if [ -n "$installed_version" ]; then
        read -p "Would you like to create a backup of your current Cursor ($installed_version) installation? (y/N) " backup_choice
        if [[ $backup_choice =~ ^[Yy]$ ]]; then
            echo "Creating backup..."
            if ! create_backup; then
                echo "Warning: Backup creation failed. Proceeding with installation..."
            else
                echo "Backup created successfully."
            fi
        fi
    fi

    local should_be_reverted=false

    echo "Installing Cursor version $version..."

    # Run create-desktop.sh to create desktop entry
    echo "Running create-desktop.sh to create desktop entry..."
    if ! ./create-desktop.sh; then
        echo "Error: Failed to run create-desktop.sh."
        should_be_reverted=true
    else
        echo "Desktop entry creation completed successfully."
    fi

    # If any step failed, restore from temporary backup
    if [ "$should_be_reverted" = true ]; then
        echo "Installation failed. Attempting to restore from temporary backup..."
        restore_temporary_backup
        return 1
    fi

    # Clean up temporary files
    echo "Cleaning up temporary files..."

    # Remove tmp directory
    if [ -d "$TEMP_DIR" ]; then
        echo "Removing tmp directory..."
        rm -rf "$TEMP_DIR"
    fi

    # Clean up temporary backup
    cleanup_temporary_backup

    # Legacy cleanup
    if [ -d "$HOME/.local/share/applications/cursor" ]; then
        echo "Removing legacy directory..."
        rm -rf "$HOME/.local/share/applications/cursor"
    fi

    echo "Cleanup completed."

    # Return failure if should_be_reverted is true
    if [ "$should_be_reverted" = true ]; then
        return 1
    fi

    return 0
}

# Function to restore from backup
restore_backup() {
    echo "Restoring from backup..."
    source ./backup.sh
    restore_backup
    return $?
}

# Function to remove a backup
remove_backup() {
    local version=$1
    if [ -d "$BACKUP_DIR/cursor_$version" ]; then
        rm -rf "$BACKUP_DIR/cursor_$version"
        echo "Backup version $version removed successfully."
        return 0
    else
        echo "Error: Backup version $version not found."
        return 1
    fi
}

# Main menu
echo "Cursor Installation Menu"
echo "1. Install/Update Cursor"

if has_backups; then
    echo "2. Manage Backups"
    echo "Available backup versions:"
    get_backup_versions | while read version; do
        echo "   - Version $version"
    done
    echo -n "Please select an option (1-2): "
    read choice

    if [ "$choice" = "2" ]; then
        echo "Select a backup version:"
        # Use mapfile to handle spaces in version names
        mapfile -t backups < <(get_backup_versions)
        for i in "${!backups[@]}"; do
            echo "[$i] Version ${backups[$i]}"
        done
        read -p "Enter the number of the backup to manage: " backup_choice
        
        if [[ "$backup_choice" =~ ^[0-9]+$ ]] && [ "$backup_choice" -lt ${#backups[@]} ]; then
            selected_version=$(basename "${backups[$backup_choice]}" | sed 's/cursor_//')
            echo "Selected backup version $selected_version"
            echo "1. Restore to this backup"
            echo "2. Remove this backup"
            read -p "Choose an action (1-2): " action_choice
            
            case $action_choice in
                1)
                    restore_backup "$selected_version"
                    ;;
                2)
                    remove_backup "$selected_version"
                    ;;
                *)
                    echo "Invalid choice. Exiting..."
                    exit 1
                    ;;
            esac
        else
            echo "Invalid backup selection. Exiting..."
            exit 1
        fi
    fi
else
    echo "2. Manage Backups (No Backups)"
    echo "No backups found. Proceeding with installation..."
    choice=1
fi

case $choice in
    1)
        install_update
        ;;
    2)
        if ! has_backups; then
            # install_update
            echo "No backups found. Exiting..."
            exit 1
        fi
        ;;
    *)
        echo "Invalid option. Exiting..."
        exit 1
        ;;
esac
