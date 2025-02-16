#!/bin/bash
# Define the log file
LOG_FILE="/var/log/linux_update.log"
# Ensure the log file is writable and reset it for a fresh log
echo "===== Linux Update Log - $(date) =====" > "$LOG_FILE"
# Check if the script is run with sudo or root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo privileges." | tee -a "$LOG_FILE"
    exit 1
fi
# Function to update Red Hat-based distributions
update_redhat() {
    echo "===== Red Hat-based Update =====" | tee -a "$LOG_FILE"
    yum update -y && yum upgrade -y | tee -a "$LOG_FILE"
}
# Function to update Debian-based distributions
update_debian() {
    echo "===== Debian-based Update =====" | tee -a "$LOG_FILE"
    apt update -y | tee -a "$LOG_FILE"
    apt upgrade -y | tee -a "$LOG_FILE"
    echo "===== Fixing Dependencies =====" | tee -a "$LOG_FILE"
    apt install -f -y | tee -a "$LOG_FILE"
    echo "===== Autoremove Unused Packages =====" | tee -a "$LOG_FILE"
    apt autoremove -y | tee -a "$LOG_FILE"
}
# Function to update Arch Linux-based distributions
update_arch() {
    echo "===== Arch Linux-based Update =====" | tee -a "$LOG_FILE"
    yes | pacman -Syu | tee -a "$LOG_FILE"

    # Check if yay is installed
    if command -v yay &> /dev/null; then
        echo "===== Updating AUR Packages with Yay =====" | tee -a "$LOG_FILE"

        # Get the non-root user running the script
        USERNAME=$(logname)

        # Run yay as the non-root user
        sudo -u "$USERNAME" yay -Syu --noconfirm | tee -a "$LOG_FILE"
    else
        echo "Yay is not installed. Skipping AUR package updates." | tee -a "$LOG_FILE"
    fi
}
# Function to update SUSE-based distributions
update_suse() {
    echo "===== SUSE-based Update =====" | tee -a "$LOG_FILE"
    zypper --non-interactive update | tee -a "$LOG_FILE"
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
    echo "This script does not support your Linux distribution." | tee -a "$LOG_FILE"
    exit 1
fi
echo "===== Update Completed on $(date) =====" | tee -a "$LOG_FILE"
