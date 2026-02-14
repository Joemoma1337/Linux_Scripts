#!/bin/bash

# --- Script Safety ---
set -e          # Exit on error
set -u          # Error on unset variables
set -o pipefail # Catch errors in piped commands

# --- Configuration ---
LOG_FILE="/var/log/linux_update.log"
# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# --- Helper Functions ---
log_section() { echo -e "\n\033[1;34m[$(date +'%H:%M:%S')] $1\033[0m"; }

# Check for root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root (use sudo)."
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
}

update_arch() {
    log_section ">>> Updating Arch Linux (Pacman)"
    # Update official repos first
    pacman -Syu --noconfirm

    # Identify the AUR helper (yay or paru)
    local AUR_HELPER
    AUR_HELPER=$(command -v yay || command -v paru || echo "")

    if [[ -n "$AUR_HELPER" ]]; then
        local REAL_USER
        REAL_USER=$(logname || echo "${SUDO_USER:-}")

        if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
            log_section ">>> Updating AUR packages via $AUR_HELPER"
            
            # --noconfirm: Don't ask for permission
            # --needed: Don't reinstall up-to-date packages
            # --devel: Check for updates in development (-git) packages
            sudo -u "$REAL_USER" "$AUR_HELPER" -Syu --noconfirm --needed --devel
        fi
    fi
}

update_suse() {
    log_section ">>> Updating SUSE (Zypper)"
    zypper --non-interactive refresh
    zypper --non-interactive patch
    zypper --non-interactive update -y
}

update_universal() {
    # This runs regardless of the Distro
    if command -v flatpak &> /dev/null; then
        log_section ">>> Updating Flatpaks"
        flatpak update -y
    fi
    if command -v snap &> /dev/null; then
        log_section ">>> Updating Snaps"
        snap refresh
    fi
}

# --- Main OS Detection Logic ---
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    
    # Try ID first, then fallback to ID_LIKE
    case "${ID:-}" in
        debian|ubuntu|mint|kali|pop|zorin|raspberrypi) update_debian ;;
        fedora|rhel|centos|almalinux|rocky) update_redhat ;;
        arch|manjaro|endeavouros) update_arch ;;
        sles|opensuse*) update_suse ;;
        *)
            # Check ID_LIKE if ID didn't match
            case "${ID_LIKE:-}" in
                *debian*|*ubuntu*) update_debian ;;
                *rhel*|*fedora*)   update_redhat ;;
                *arch*)            update_arch ;;
                *suse*)            update_suse ;;
                *) echo "Error: OS not supported."; exit 1 ;;
            esac
            ;;
    esac
    
    update_universal
else
    echo "Critical: /etc/os-release not found."
    exit 1
fi

log_section "Update Process Completed Successfully"
