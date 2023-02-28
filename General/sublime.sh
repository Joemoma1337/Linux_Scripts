#!/bin/bash
# Check which Linux distribution is running
if [ -f /etc/redhat-release ]; then
    # Install Sublime on Red Hat-based distributions
    sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
    sudo yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
    sudo yum install -y sublime-text
elif [ -f /etc/debian_version ]; then
    # Install Sublime on Debian-based distributions
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get update
    sudo apt-get install -y sublime-text
elif [ -f /etc/arch-release ]; then
    # Install Sublime on Arch Linux-based distributions
    sudo pacman -S sublime-text
elif [ -f /etc/SuSE-release ]; then
    # Install Sublime on SuSE-based distributions
    sudo zypper addrepo -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
    sudo zypper install -y sublime-text
else
    echo "This script does not support your Linux distribution."
fi
