#!/bin/bash
# Optimized 4K Video Downloader+ Maintenance Script

# --- Script Safety ---
set -euo pipefail

# --- Configuration ---
# Change this to the directory containing your .deb files
readonly DEB_DIR="${HOME}/Downloads"
readonly APP_NAME="4kvideodownloaderplus"
readonly APP_PROCESS="$APP_NAME-bin"
readonly APP_DISPLAY_NAME="4K Video Downloader+"
#readonly DOWNLOAD_PATH="${HOME}/Downloads/4kdl.deb"

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
    log_info "Searching for the latest version of $APP_NAME in $DEB_DIR..."

    # 1. Find all matching .deb files
    # 2. Sort them by version number (highest at the bottom)
    # 3. Take the last (newest) one
    local latest_deb
    latest_deb=$(ls "$DEB_DIR"/${APP_NAME}_*_amd64.deb 2>/dev/null | sort -V | tail -n 1)

    if [ -n "$latest_deb" ] && [ -f "$latest_deb" ]; then
        log_info "Latest version found: $(basename "$latest_deb")"
        log_info "Installing..."
        sudo apt-get install -y "$latest_deb"
    else
        log_error "No installation files matching ${APP_NAME}_*_amd64.deb found in $DEB_DIR"
    fi
}

# --- Main Execution ---

check_privileges
kill_app
backup_data
uninstall_and_clean
reinstall_app

log_info "Process successfully completed."
