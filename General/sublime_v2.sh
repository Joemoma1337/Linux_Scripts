#!/bin/bash

# Function to install Sublime Text
install_sublime() {
    echo "Installing Sublime Text on $1..."
    case $1 in
        redhat)
            sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
            sudo yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
            sudo yum install -y sublime-text
            ;;
        debian)
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sublimehq-archive.gpg
            echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y sublime-text
            ;;
        arch)
            sudo pacman -S --noconfirm sublime-text
            ;;
        suse)
            sudo zypper addrepo -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
            sudo zypper install -y sublime-text
            ;;
        *)
            echo "This script does not support your Linux distribution."
            exit 1
            ;;
    esac
}

# Check which Linux distribution is running
if [ -f /etc/redhat-release ]; then
    install_sublime redhat
elif [ -f /etc/debian_version ]; then
    install_sublime debian
elif [ -f /etc/arch-release ]; then
    install_sublime arch
elif [ -f /etc/SuSE-release ]; then
    install_sublime suse
else
    echo "Unsupported Linux distribution."
fi
