#!/bin/bash
# Check which Linux distribution is running
if [ -f /etc/redhat-release ]; then
    # Update for Red Hat-based distributions
        echo "" && echo "===== Update ======" && yum update -y
        echo "" && echo "===== upgrade ======" && yum upgrade -y
elif [ -f /etc/debian_version ]; then
    # Update for Debian-based distributions
        echo "" && echo "===== Update ======" && apt -y update
        echo "" && echo "===== Dist-Upgrade =====" && apt -y dist-upgrade
        echo "" && echo "===== Upgrade ======" && apt -y upgrade
        echo "" && echo "===== Fix Dependancies ======" && apt -y install -f
        echo "" && echo "===== Autoremove ======" && apt -y autoremove
elif [ -f /etc/arch-release ]; then
    # Update for Arch Linux-based distributions
		echo "" && echo "===== Starting update =====" && yes | pacman -Syu
elif [ -f /etc/SuSE-release ]; then
    # Update for SuSE-based distributions
         echo "" && echo "===== Starting update =====" && zypper --non-interactive update
else
    echo "This script does not support your Linux distribution."
fi
