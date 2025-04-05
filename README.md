# Cursor for Linux Installer

This is an installation/update script for Cursor on Linux (tested on Gnome). The script:

- Downloads the latest version of Cursor
- Installs it on your system
- Creates a desktop icon for easy access
- Fixes known bugs:
  - Double title bar issue
  - Drag and drop not working
- Adds Cursor to the "Open with..." menu

When run again, it acts as an update tool, ensuring you always have the latest version with all fixes applied.

## Automatic Installation

1. Run `install.sh` by writing in console

```sh
./install.sh
```

## Manual Installation

1. Download Cursor for Linux:
   - Place it in this folder and rename to `Cursor.AppImage`
   - Or run `download.sh`
2. Run `fix-header.sh`
3. Run `create-desktop.sh`
