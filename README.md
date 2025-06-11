# Cursor for Linux Installer

This is an installation/update script for Cursor on Linux (tested on Gnome, Cursor 0.48.2, 0.49.6). The script:

- Downloads the latest version of Cursor
- Installs it on your system
- Creates a desktop icon for easy access
- Fixes known bugs:
  - Double title bar issue
  - Drag and drop not working
  - URL handler (can sign in into extensions e.g GitLens)
- Adds Cursor to the "Open with..." menu
- Manages backups

When run again, it acts as an update tool, ensuring you always have the latest version with all fixes applied.

## Quickstart

To quickly download and install Cursor, run the following command:

```sh
git clone https://github.com/Mapuut/Cursor-Installer.git && cd Cursor-Installer && ./install.sh
```

## Automatic Installation

1. Run `install.sh` by typing in your console:

```sh
./install.sh
```

## Manual Installation

1. Download Cursor for Linux:
   - Place it in this `tmp/` folder and rename to `Cursor.AppImage`
   - Or run `download.sh`
2. Run `fix-header.sh`
3. Run `create-desktop.sh`

## Common Issues

### Sign In/Sign Up Buttons Not Working

If clicking the Sign In or Sign Up buttons doesn't open anything:

1. Change your default browser in your system settings
2. Try clicking the buttons again

This issue typically occurs with Firefox, updating/downgrading browser might solve issue as well. Issue is with browser or Cursor itself, **NOT** a side effect of this installer.

