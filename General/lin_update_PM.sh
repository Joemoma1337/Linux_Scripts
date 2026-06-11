#!/bin/bash

# Ensure the script is NOT run as root initially, so user-space managers (yay/flatpak) work.
# The script will ask for sudo password only when running system updates.
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user (without sudo)."
    echo "The script will request sudo privileges automatically when needed."
    exit 1
fi

echo "========================================"
echo "   Starting Universal Linux Update     "
echo "========================================"

# Track if a system update was performed
SYSTEM_UPDATED=false

# 1. Detect and execute Core System Updates
if command -v apt-get &> /dev/null; then
    echo "--> Debian/Ubuntu-based system detected (APT)"
    sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
    SYSTEM_UPDATED=true

elif command -v dnf &> /dev/null; then
    echo "--> RHEL/Fedora-based system detected (DNF)"
    sudo dnf upgrade -y && sudo dnf autoremove -y
    SYSTEM_UPDATED=true

# Arch Logic: Check for AUR helpers first, as they update both repo & AUR packages simultaneously
elif command -v yay &> /dev/null; then
    echo "--> Arch-based system detected (Yay AUR Helper)"
    yay -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v paru &> /dev/null; then
    echo "--> Arch-based system detected (Paru AUR Helper)"
    paru -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v pacman &> /dev/null; then
    echo "--> Arch-based system detected (Pacman)"
    sudo pacman -Syu --noconfirm
    SYSTEM_UPDATED=true

elif command -v zypper &> /dev/null; then
    echo "--> openSUSE-based system detected (Zypper)"
    sudo zypper refresh && sudo zypper update -y
    SYSTEM_UPDATED=true

elif command -v apk &> /dev/null; then
    echo "--> Alpine-based system detected (APK)"
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

# 2. Check for Flatpak (Runs as user, no sudo needed)
if command -v flatpak &> /dev/null; then
    echo "--> Updating Flatpak packages..."
    flatpak update -y
else
    echo "--> Flatpak not installed/used. Skipping."
fi

# 3. Check for Snap (Requires sudo)
if command -v snap &> /dev/null; then
    echo "--> Updating Snap packages..."
    sudo snap refresh
else
    echo "--> Snap not installed/used. Skipping."
fi

echo -e "\n========================================"
echo "       All Updates Completed!           "
echo "========================================"
