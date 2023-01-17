#!/bin/bash
# Check which Linux distribution is running
if [ -f /etc/redhat-release ]; then
    # Update for Red Hat-based distributions
    sudo yum update
elif [ -f /etc/debian_version ]; then
    # Update for Debian-based distributions
    sudo apt-get update
    sudo apt-get upgrade -y
elif [ -f /etc/arch-release ]; then
    # Update for Arch Linux-based distributions
    sudo pacman -Syu
elif [ -f /etc/SuSE-release ]; then
    # Update for SuSE-based distributions
    sudo zypper update
else
    echo "This script does not support your Linux distribution."
fi
