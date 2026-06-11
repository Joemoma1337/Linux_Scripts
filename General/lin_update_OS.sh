#!/bin/bash

# --- Script Safety ---
set -euo pipefail

# --- Configuration ---
LOG_FILE="/var/log/linux_update.log"
mkdir -p "$(dirname "$LOG_FILE")"

# --- Helper Functions ---
log_section() { 
    echo -e "\n\033[1;34m[$(date +'%H:%M:%S')] $1\033[0m"
}

log_warn() {
    echo -e "\033[1;33m[!] $1\033[0m"
}

# Check for root
if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run as root (use sudo)." >&2
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
    local MANAGER
    MANAGER=$(command -v dnf || command -v yum)
    $MANAGER makecache
    $MANAGER upgrade -y
    $MANAGER autoremove -y
    $MANAGER clean all
}

update_arch() {
    log_section ">>> Updating Arch Linux (Pacman)"
    pacman -Syu --noconfirm

    # Safely check for AUR Helpers without breaking set -e
    local AUR_HELPER=""
    if command -v yay &>/dev/null; then AUR_HELPER="yay"; 
    elif command -v paru &>/dev/null; then AUR_HELPER="paru"; fi

    if [[ -n "$AUR_HELPER" ]]; then
        local REAL_USER
        REAL_USER=$(logname || echo "${SUDO_USER:-}")
        if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
            log_section ">>> Updating AUR packages via $AUR_HELPER"
            # Note: This requires the user to have passwordless sudo access for AUR upgrades to be fully automated
            if sudo -u "$REAL_USER" -n true 2>/dev/null; then
                sudo -u "$REAL_USER" env PATH="$PATH" "$AUR_HELPER" -Syu --noconfirm --needed || log_warn "AUR update failed."
            else
                log_warn "Skipping AUR updates: User $REAL_USER requires a password for sudo commands."
            fi
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
    apk upgrade --available
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
    
    # 1. Debian/Ubuntu style
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "\033[1;31m[!] System reboot required (found /var/run/reboot-required)\033[0m"
        return
    fi
    
    # 2. Red Hat/Fedora style
    if command -v needs-restarting &> /dev/null; then
        if ! needs-restarting -r > /dev/null; then
            echo -e "\033[1;31m[!] System reboot required (detected by needs-restarting)\033[0m"
            return
        fi
    fi

    # 3. Arch/Alpine generic fallback (Compares running kernel version to files on disk)
    if command -v file &>/dev/null && [[ -d /lib/modules/$(uname -r) ]]; then
        # If the modules directory for the running kernel is missing, it was upgraded
        :
    elif [[ -f /boot/vmlinuz-linux ]]; then
        # Arch specific simple check
        local running_kernel
        running_kernel="core-$(uname -r)"
        # Simple alert if pacman log recently pulled down a new linux kernel
        if tail -n 20 /var/log/pacman.log | grep -E "upgraded linux \(" &>/dev/null; then
             echo -e "\033[1;31m[!] System reboot required (New Linux kernel detected via pacman log)\033[0m"
        fi
    fi
}

# --- Main OS Detection Logic ---

# We parse os-release first as a primary source of truth, fallback to command binary checks
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID="${ID_LIKE:-$ID}"
else
    OS_ID="unknown"
fi

case "$OS_ID" in
    *debian*|*ubuntu*)
        update_debian ;;
    *rhel*|*fedora*|*centos*)
        update_redhat ;;
    *arch*)
        update_arch ;;
    *suse*)
        update_suse ;;
    *alpine*)
        update_alpine ;;
    *)
        # Fallback to pure CLI detection if os-release lied or didn't exist
        log_warn "OS-release match failed. Attempting binary fallback detection..."
        if command -v apt-get &> /dev/null;      then update_debian;
        elif command -v dnf &> /dev/null;        then update_redhat;
        elif command -v yum &> /dev/null;        then update_redhat;
        elif command -v pacman &> /dev/null;     then update_arch;
        elif command -v zypper &> /dev/null;     then update_suse;
        elif command -v apk &> /dev/null;        then update_alpine;
        else
            echo "Error: Could not detect package manager or unsupported OS type." >&2
            exit 1
        fi
        ;;
esac

# Always attempt universal package updates
update_universal

# Final Check
check_reboot

log_section "Update Process Completed Successfully"
