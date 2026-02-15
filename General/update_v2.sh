#!/bin/bash

# --- Script Safety ---
set -e          # Exit on error
set -u          # Error on unset variables
set -o pipefail # Catch errors in piped commands

# --- Configuration ---
LOG_FILE="/var/log/linux_update.log"
mkdir -p "$(dirname "$LOG_FILE")"

# --- Helper Functions ---
log_section() { echo -e "\n\033[1;34m[$(date +'%H:%M:%S')] $1\033[0m"; }

# Check for root
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run as root (use sudo)."
    exit 1
fi

# Logging setup (Terminal + File)
exec > >(tee -a "$LOG_FILE") 2>&1

log_section "Update Process Started"

# --- Update Logic Functions ---

update_debian() {
    log_section ">>> Updating Debian-based (Apt)"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get full-upgrade -y
    apt-get autoremove -y
    apt-get autoclean
}

update_redhat() {
    log_section ">>> Updating Red Hat-based (DNF/Yum)"
    local MANAGER; MANAGER=$(command -v dnf || command -v yum)
    $MANAGER makecache
    $MANAGER upgrade -y
    $MANAGER autoremove -y
    $MANAGER clean all
}

update_arch() {
    log_section ">>> Updating Arch Linux (Pacman)"
    pacman -Syu --noconfirm

    # Check for AUR Helpers (yay/paru)
    local AUR_HELPER
    AUR_HELPER=$(command -v yay || command -v paru || echo "")

    if [[ -n "$AUR_HELPER" ]]; then
        local REAL_USER
        REAL_USER=$(logname || echo "${SUDO_USER:-}")
        if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
            log_section ">>> Updating AUR packages via $AUR_HELPER"
            # Use 'env PATH' to ensure the user's path is respected
            sudo -u "$REAL_USER" env PATH="$PATH" "$AUR_HELPER" -Syu --noconfirm --needed
        fi
    fi
}

update_suse() {
    log_section ">>> Updating SUSE (Zypper)"
    zypper --non-interactive refresh
    zypper --non-interactive patch
    zypper --non-interactive update -y
}

update_alpine() {
    log_section ">>> Updating Alpine (APK)"
    apk update
    apk upgrade
}

update_universal() {
    if command -v flatpak &> /dev/null; then
        log_section ">>> Updating Flatpaks"
        flatpak update -y
    fi
    if command -v snap &> /dev/null; then
        log_section ">>> Updating Snaps"
        snap refresh
    fi
}

check_reboot() {
    log_section "Checking if Reboot is Required..."
    
    # Debian/Ubuntu style
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "\033[1;31m[!] System reboot required (found /var/run/reboot-required)\033[0m"
        return
    fi
    
    # Red Hat/Fedora/Arch style (checking if running kernel != installed kernel)
    if command -v needs-restarting &> /dev/null; then
        # dnf-utils/yum-utils tool
        if ! needs-restarting -r > /dev/null; then
            echo -e "\033[1;31m[!] System reboot required (detected by needs-restarting)\033[0m"
        fi
    fi
}

# --- Main Hybrid Detection Logic ---

# Check for tools in order of popularity/commonality
if command -v apt-get &> /dev/null; then
    update_debian
elif command -v dnf &> /dev/null || command -v yum &> /dev/null; then
    update_redhat
elif command -v pacman &> /dev/null; then
    update_arch
elif command -v zypper &> /dev/null; then
    update_suse
elif command -v apk &> /dev/null; then
    update_alpine
else
    # Fallback: Last ditch effort using os-release if tools aren't in PATH
    if [[ -f /etc/os-release ]]; then
        log_section "Tools not in PATH, attempting OS-release fallback..."
        . /etc/os-release
        case "${ID_LIKE:-$ID}" in
            *debian*|*ubuntu*) update_debian ;;
            *rhel*|*fedora*)   update_redhat ;;
            *arch*)            update_arch ;;
            *suse*)            update_suse ;;
            *) echo "Error: OS not supported."; exit 1 ;;
        esac
    else
        echo "Error: Could not detect package manager or OS type."
        exit 1
    fi
fi

# Always attempt universal package updates
update_universal

# Final Check
check_reboot

log_section "Update Process Completed Successfully"
