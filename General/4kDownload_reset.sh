#!/bin/bash
# Optimized 4K Video Downloader+ Maintenance Script

# --- Script Safety ---
set -euo pipefail

# --- Configuration ---
readonly APP_NAME="4kvideodownloaderplus"
readonly APP_PROCESS="$APP_NAME-bin"
readonly APP_DISPLAY_NAME="4K Video Downloader+"
readonly DOWNLOAD_PATH="${HOME}/Downloads/4kdl.deb"

# Standard XDG Paths
readonly VIDEO_DIR="$(xdg-user-dir VIDEOS 2>/dev/null || echo "${HOME}/Videos")/${APP_DISPLAY_NAME}"
readonly BACKUP_DIR="$(xdg-user-dir VIDEOS 2>/dev/null || echo "${HOME}/Videos")/backup_$(date +%Y%m%d)"

# --- Helper Functions ---
log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

# Check for root at start to prevent mid-script password prompts
check_privileges() {
    if ! sudo -v; then
        log_error "This script requires sudo privileges to uninstall/reinstall software."
    fi
}

# --- Process Logic ---

kill_app() {
    log_info "Stopping instances of '$APP_PROCESS'..."
    # killall is more direct; || true prevents script exit if process not found
    killall -q "$APP_PROCESS" || true
}

backup_data() {
    if [ -d "$VIDEO_DIR" ] && [ "$(ls -A "$VIDEO_DIR")" ]; then
        log_info "Moving contents from $VIDEO_DIR to $BACKUP_DIR..."
        
        # Create the backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"
        
        # Move all contents (files and subfolders)
        mv "$VIDEO_DIR"/* "$BACKUP_DIR/"
        
        log_info "Backup complete."
    else
        log_info "No files found in $VIDEO_DIR to back up."
    fi
}

uninstall_and_clean() {
    log_info "Purging $APP_NAME and removing configuration..."
    
    # Check installation status using a faster silent check
    if dpkg -s "$APP_NAME" &>/dev/null; then
        sudo apt-get purge -y "$APP_NAME"
    fi

    # Leftover paths (using XDG variables where possible)
    local leftover_paths=(
        "${HOME}/.local/share/4kdownload.com"
        "${HOME}/.cache/4kdownload.com"
        "${HOME}/.config/4kdownload.com"
    )

    for path in "${leftover_paths[@]}"; do
        if [ -d "$path" ]; then
            log_warn "Removing leftover: $path"
            rm -rf "$path"
        fi
    done
}

reinstall_app() {
    if [ -f "$DOWNLOAD_PATH" ]; then
        log_info "Installing from $DOWNLOAD_PATH..."
        # Using apt install on a local file handles dependencies automatically
        sudo apt-get install -y "$DOWNLOAD_PATH"
    else
        log_error "Installation file not found: $DOWNLOAD_PATH"
    fi
}

# --- Main Execution ---

check_privileges
kill_app
backup_data
uninstall_and_clean
reinstall_app

log_info "Process successfully completed."
