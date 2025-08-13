#!/bin/bash
#
# V3: Optimized script to back up, fully uninstall, clean, and reinstall
# the 4K Video Downloader Plus application using precise path removal.
#

# --- Script Safety ---
set -euo pipefail

# --- Configuration ---
USER_HOME="${HOME}"
VIDEO_PARENT_DIR=$(xdg-user-dir VIDEOS 2>/dev/null || echo "${USER_HOME}/Videos")

readonly APP_NAME="4kvideodownloaderplus"
readonly APP_DISPLAY_NAME="4K Video Downloader+"
readonly VIDEO_DIR="${VIDEO_PARENT_DIR}/${APP_DISPLAY_NAME}"
readonly BACKUP_DIR="${VIDEO_PARENT_DIR}/backup_$(date +%Y-%m-%d_%H%M%S)"
readonly DOWNLOAD_PATH="${USER_HOME}/Downloads/4kdl.deb"

# --- Helper Functions ---
log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
}

# --- Main Functions ---

kill_app() {
    log_info "Checking for running instances of '$APP_DISPLAY_NAME'..."
    if pgrep -fi "$APP_NAME" > /dev/null; then
        pkill -fi "$APP_NAME"
        log_info "Stopped running application processes."
    else
        log_info "Application is not running."
    fi
}

backup_data() {
    log_info "Checking for files to back up in '$VIDEO_DIR'..."
    if [ -d "$VIDEO_DIR" ] && find "$VIDEO_DIR" -mindepth 1 -print -quit | grep -q .; then
        log_info "Backup directory will be: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv -v "$VIDEO_DIR"/* "$BACKUP_DIR"/
        log_info "Backup completed."
    else
        log_info "No files found to back up."
    fi
}

uninstall_app() {
    log_info "Checking if '$APP_NAME' is installed..."
    if dpkg-query -W -f='${Status}' "$APP_NAME" 2>/dev/null | grep -q "ok installed"; then
        log_info "Uninstalling and purging '$APP_NAME'..."
        sudo apt-get purge -y "$APP_NAME"
        log_info "Application purged successfully."
    else
        log_info "Application is not installed."
    fi
}

cleanup_leftover_files() {
    log_info "Removing known application directories (cache, config, data)..."

    # Define a list of specific paths to remove.
    # This is much safer and faster than searching the filesystem.
    readonly LEFTOVER_PATHS=(
        "${USER_HOME}/.local/share/4kdownload.com"
        "${USER_HOME}/.cache/4kdownload.com"
        "${USER_HOME}/.config/4kdownload.com"
    )

    for path in "${LEFTOVER_PATHS[@]}"; do
        # Check if the file or directory actually exists before trying to remove it.
        if [ -e "$path" ]; then
            log_warn "Found leftover at: $path"
            # Use 'rm -rfi' to prompt for confirmation. THIS IS THE SAFEST OPTION.
            rm -rf "$path"
        else
            log_info "Path not found (already clean): $path"
        fi
    done

    log_info "Known leftover file cleanup finished."
}

reinstall_app() {
    log_info "Attempting to reinstall from '$DOWNLOAD_PATH'..."
    if [ -f "$DOWNLOAD_PATH" ]; then
        sudo dpkg -i "$DOWNLOAD_PATH"
        log_info "Installation finished. Now fixing any broken dependencies..."
        sudo apt-get install --fix-broken -y
        log_info "Application reinstalled and dependencies fixed."
    else
        log_warn "Installation file not found: $DOWNLOAD_PATH. Cannot reinstall."
    fi
}

# --- Main Script Execution ---

log_info "Starting cleanup and reinstall process for '$APP_DISPLAY_NAME'..."

kill_app
backup_data
uninstall_app
cleanup_leftover_files
reinstall_app

log_info "Process completed."
