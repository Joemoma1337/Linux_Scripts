#!/bin/bash
set -e  # Exit immediately if a command fails

# Define variables
APP_NAME="4kvideodownloaderplus"
BACKUP_DIR="/home/standard/Videos/backup"
VIDEO_DIR="/home/USER/Videos/4K Video Downloader+"
DOWNLOAD_PATH="/home/USER/Downloads/4kdl.deb"

# Kill the application if running
if pgrep -f "$APP_NAME" > /dev/null; then
    pkill -f "$APP_NAME"
    echo "Stopped running processes of $APP_NAME."
fi

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Move files to backup if they exist
if [ -d "$VIDEO_DIR" ] && [ "$(ls -A "$VIDEO_DIR")" ]; then
    mv "$VIDEO_DIR"/* "$BACKUP_DIR"/
    echo "Backup completed: Files moved from $VIDEO_DIR to $BACKUP_DIR."
else
    echo "No files to backup in $VIDEO_DIR."
fi

# Remove application
if dpkg -l | grep -q "$APP_NAME"; then
    sudo apt -y remove "$APP_NAME"
    echo "$APP_NAME removed successfully."
else
    echo "$APP_NAME is not installed."
fi

# Find and remove leftover files
find / \
    \( -path "/home/USER/Downloads" -o -path "/mnt" \) -prune \
    -o -iname '4k*video*' -print0 2>/dev/null | while IFS= read -r -d '' file; do
        echo "Removing: $file"
        rm -rf "$file"
    done

# Reinstall the application
if [ -f "$DOWNLOAD_PATH" ]; then
    sudo dpkg -i "$DOWNLOAD_PATH"
    echo "Reinstalled from $DOWNLOAD_PATH."
else
    echo "Installation file not found: $DOWNLOAD_PATH."
fi
