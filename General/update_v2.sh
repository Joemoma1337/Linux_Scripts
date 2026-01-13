#!/bin/bash

# --- Configuration ---
LOG_FILE="/var/log/linux_update.log"

# --- Script Safety & Global Logging ---
# Ensure script runs as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

# Redirect all stdout and stderr to the log file AND the terminal
exec > >(tee -a "$LOG_FILE") 2>&1

echo "--------------------------------------------------"
echo "Update Started: $(date)"
echo "--------------------------------------------------"

# --- Update Logic Functions ---

update_debian() {
    echo ">>> Starting Debian-based (Apt) Update"
    apt update -y
    apt full-upgrade -y  # Better than 'upgrade' as it handles dependency changes
    apt install -f -y
    apt autoremove -y
    apt clean
}

update_redhat() {
    echo ">>> Starting Red Hat-based (DNF/Yum) Update"
    # Use dnf if available, otherwise fallback to yum
    MANAGER=$(command -v dnf || command -v yum)
    $MANAGER update -y
    $MANAGER autoremove -y
}

update_arch() {
    echo ">>> Starting Arch Linux (Pacman) Update"
    pacman -Syu --noconfirm
    
    # AUR Update (Yay) - Only runs if yay exists and a real user is detected
    if command -v yay &> /dev/null; then
        REAL_USER=$(logname || echo $SUDO_USER)
        if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
            echo ">>> Updating AUR packages as user: $REAL_USER"
            sudo -u "$REAL_USER" yay -Syu --noconfirm
        fi
    fi
}

update_suse() {
    echo ">>> Starting SUSE (Zypper) Update"
    zypper --non-interactive patch
    zypper --non-interactive update
}

# --- Main OS Detection Logic ---
# Using /etc/os-release is the standard for modern distros
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu|mint|kali|pop) update_debian ;;
        fedora|rhel|centos|almalinux|rocky) update_redhat ;;
        arch|manjaro|endeavouros) update_arch ;;
        sles|opensuse*) update_suse ;;
        *) echo "OS ID '$ID' not supported."; exit 1 ;;
    esac
else
    echo "Critical: /etc/os-release not found. Cannot detect OS."
    exit 1
fi

echo "--------------------------------------------------"
echo "Update Completed: $(date)"
echo "--------------------------------------------------"
