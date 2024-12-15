#!/bin/bash

# Check if the script is run with sudo or root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo privileges."
    exit 1
fi

# Function to update Red Hat-based distributions
update_redhat() {
    echo "===== Red Hat-based Update ====="
    yum update -y && yum upgrade -y
}

# Function to update Debian-based distributions
update_debian() {
    echo "===== Debian-based Update ====="
    apt update -y && apt upgrade -y
    echo "===== Fixing Dependencies ====="
    apt install -f -y
    echo "===== Autoremove Unused Packages ====="
    apt autoremove -y
}

# Function to update Arch Linux-based distributions
update_arch() {
    echo "===== Arch Linux-based Update ====="
    yes | pacman -Syu
}

# Function to update SUSE-based distributions
update_suse() {
    echo "===== SUSE-based Update ====="
    zypper --non-interactive update
}

# Main script logic
if [ -f /etc/redhat-release ]; then
    update_redhat
elif [ -f /etc/debian_version ]; then
    update_debian
elif [ -f /etc/arch-release ]; then
    update_arch
elif [ -f /etc/SuSE-release ]; then
    update_suse
else
    echo "This script does not support your Linux distribution."
    exit 1
fi
