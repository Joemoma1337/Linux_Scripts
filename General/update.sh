#!/bin/bash
# A robust script to update various Linux distributions.

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error.
# The return value of a pipeline is the status of the last command to exit with a non-zero status.
set -euo pipefail

# --- Configuration ---
readonly LOG_FILE="/var/log/linux_update.log"

# --- Functions ---

# Function to log messages to both stdout and the log file
log_message() {
    echo "===== $1 =====" | tee -a "$LOG_FILE"
}

# Function to run a command and log its output
run_command() {
    log_message "$1"
    # The command to be run is passed as all subsequent arguments
    "${@:2}" 2>&1 | tee -a "$LOG_FILE"
}

update_debian_family() {
    # Ensure apt doesn't ask any interactive questions
    export DEBIAN_FRONTEND=noninteractive
    run_command "Updating package lists" apt-get update -y
    run_command "Upgrading packages" apt-get upgrade -y
    run_command "Performing distribution upgrade" apt-get dist-upgrade -y
    run_command "Fixing broken dependencies" apt-get install -f -y
    run_command "Autoremoving unused packages" apt-get autoremove -y
}

update_rhel_family() {
    # Prefer DNF, fall back to YUM
    if command -v dnf &> /dev/null; then
        run_command "Upgrading packages with DNF" dnf upgrade -y
    else
        run_command "Upgrading packages with YUM" yum update -y
    fi
}

update_arch_family() {
    run_command "Updating official packages with Pacman" pacman -Syu --noconfirm

    # Check for AUR helper (yay) and run it as the non-root user
    if command -v yay &> /dev/null; then
        # Check if the script was run with sudo. If so, SUDO_USER is set.
        if [ -n "${SUDO_USER-}" ]; then
            log_message "Updating AUR packages with Yay for user: $SUDO_USER"
            # The `sudo -u` command itself is run as root
            sudo -u "$SUDO_USER" yay -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
        else
            log_message "Cannot determine non-root user. Skipping AUR updates."
            echo "Please run this script with 'sudo' to enable AUR updates." | tee -a "$LOG_FILE"
        fi
    else
        log_message "Yay not found. Skipping AUR package updates."
    fi
}

update_suse_family() {
    run_command "Upgrading packages with Zypper" zypper --non-interactive update
}

# --- Main Script Logic ---

# 1. Check for root privileges FIRST
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root or with sudo privileges."
    exit 1
fi

# 2. Reset the log file now that we know we have permissions
echo "===== Linux Update Log - $(date) =====" > "$LOG_FILE"

# 3. Use /etc/os-release for reliable distro detection
if [ -f /etc/os-release ]; then
    # Source the file to get variables like ID and ID_LIKE
    . /etc/os-release
else
    log_message "Cannot find /etc/os-release. Unable to determine distribution."
    exit 1
fi

log_message "Detected Distribution ID: $ID"

# 4. Use a case statement for cleaner logic
case "$ID_LIKE" in
    *debian*)
        update_debian_family
        ;;
    *rhel*|*fedora*)
        update_rhel_family
        ;;
    *arch*)
        update_arch_family
        ;;
    *suse*)
        update_suse_family
        ;;
    *)
        # Fallback to check the ID itself if ID_LIKE is not specific enough
        case "$ID" in
            debian|ubuntu|mint)
                update_debian_family
                ;;
            rhel|centos|fedora)
                update_rhel_family
                ;;
            arch)
                update_arch_family
                ;;
            opensuse|sles)
                update_suse_family
                ;;
            *)
                log_message "This script does not support your Linux distribution: $ID"
                exit 1
                ;;
        esac
        ;;
esac

log_message "Update Completed on $(date)"
exit 0
