#!/bin/bash

# Ensure the script is NOT run as root initially, so user-space managers (yay/flatpak) work.
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user (without sudo)."
    echo "The script will request sudo privileges automatically when needed."
    exit 1
fi

echo "========================================"
echo "    Starting Universal Linux Update     "
echo "========================================"

# Track if a system update was performed
SYSTEM_UPDATED=false
DISTRO_TYPE=""

# 1. Detect and execute Core System Updates
if command -v apt-get &> /dev/null; then
    echo "--> Debian/Ubuntu-based system detected (APT)"
    DISTRO_TYPE="debian"
    sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
    SYSTEM_UPDATED=true

elif command -v dnf &> /dev/null; then
    echo "--> RHEL/Fedora-based system detected (DNF)"
    DISTRO_TYPE="fedora"
    sudo dnf upgrade -y && sudo dnf autoremove -y
    SYSTEM_UPDATED=true

# Arch Logic: Check for AUR helpers first
elif command -v yay &> /dev/null; then
    echo "--> Arch-based system detected (Yay AUR Helper)"
    DISTRO_TYPE="arch"
    yay -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v paru &> /dev/null; then
    echo "--> Arch-based system detected (Paru AUR Helper)"
    DISTRO_TYPE="arch"
    paru -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v pacman &> /dev/null; then
    echo "--> Arch-based system detected (Pacman)"
    DISTRO_TYPE="arch"
    sudo pacman -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v zypper &> /dev/null; then
    echo "--> openSUSE-based system detected (Zypper)"
    DISTRO_TYPE="suse"
    sudo zypper refresh && sudo zypper update -y
    SYSTEM_UPDATED=true

elif command -v apk &> /dev/null; then
    echo "--> Alpine-based system detected (APK)"
    DISTRO_TYPE="alpine"
    sudo apk update && sudo apk upgrade
    SYSTEM_UPDATED=true
fi

# Exit if no core package manager was found
if [ "$SYSTEM_UPDATED" = false ]; then
    echo "X Error: No supported system package manager found."
    exit 1
fi

echo -e "\n========================================"
echo "   Checking Secondary/App Managers     "
echo "========================================"

# 2. Check for Flatpak
if command -v flatpak &> /dev/null; then
    echo "--> Updating Flatpak packages..."
    flatpak update -y
else
    echo "--> Flatpak not installed/used. Skipping."
fi

# 3. Check for Snap
if command -v snap &> /dev/null; then
    echo "--> Updating Snap packages..."
    sudo snap refresh
else
    echo "--> Snap not installed/used. Skipping."
fi

echo -e "\n========================================"
echo "         All Updates Completed!         "
echo "========================================"

# ==============================================================================
# NEW: Cross-Distribution Reboot Check Function
# ==============================================================================
check_reboot_required() {
    local REBOOT_NEEDED=false

    case "$DISTRO_TYPE" in
        "debian")
            if [ -f /var/run/reboot-required ]; then
                REBOOT_NEEDED=true
            fi
            ;;
        "fedora")
            # dnf-utils package provides 'needs-restarting'
            if command -v needs-restarting &> /dev/null; then
                # -r checks specifically for core components requiring a reboot
                if ! sudo needs-restarting -r &> /dev/null; then
                    REBOOT_NEEDED=true
                fi
            fi
            ;;
        "arch")
            # Arch updates the kernel binary on disk immediately. If the running kernel version
            # doesn't match the package version available in /usr/lib/modules/, a reboot is required.
            if [ -d "/usr/lib/modules/$(uname -r)" ]; then
                # If the current modules directory doesn't exist, the kernel was updated/replaced.
                :
            else
                REBOOT_NEEDED=true
            fi
            ;;
        "suse")
            if command -v zypper &> /dev/null; then
                # zypper ps -s flags if major patches require a system restart
                if sudo zypper ps -s | grep -qi "reboot"; then
                    REBOOT_NEEDED=true
                fi
            fi
            ;;
    esac

    if [ "$REBOOT_NEEDED" = true ]; then
        echo -e "\n\033[1;31m⚠️  WARNING: A system reboot is required to apply core updates.\033[0m"
        read -p "Would you like to reboot now? (y/N): " choice
        case "$choice" in 
            [yY][eE][sS]|[yY]) 
                echo "Rebooting system..."
                sudo reboot
                ;;
            *)
                echo "Please remember to reboot your system later."
                ;;
        esac
    else
        echo -e "\n✅ No system reboot is required."
    fi
}

# Run the check
check_reboot_required
