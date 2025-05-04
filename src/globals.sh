#!/bin/bash

# Global variables for Cursor Installer
# This file contains all shared variables used across different scripts

# Directories
PROJECT_ROOT=".."

DEST_DIR="$HOME/.cursor-installer/current"
DEST_DIR_DESKTOP="$HOME/.local/share/applications"

TEMP_DIR="$PROJECT_ROOT/tmp"
TEMP_DIR_EXTRACTED="$PROJECT_ROOT/tmp/squashfs-root"

BACKUP_DIR="$HOME/.cursor-installer/backups"
TEMP_BACKUP_DIR="$HOME/.cursor-installer/temp_backup"
