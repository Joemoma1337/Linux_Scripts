#!/bin/bash

# Function to install Plex Media Server on Ubuntu/Debian
install_plex_ubuntu() {
    echo "Installing Plex Media Server on Ubuntu/Debian..."
    wget -O - https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
    echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
    sudo apt update
    sudo apt install plexmediaserver -y
    echo "Plex Media Server installed successfully!"
}

# Function to install Plex Media Server on CentOS/RHEL
install_plex_centos() {
    echo "Installing Plex Media Server on CentOS/RHEL..."
    sudo yum install epel-release -y
    sudo yum install plexmediaserver -y
    sudo systemctl enable plexmediaserver
    sudo systemctl start plexmediaserver
    echo "Plex Media Server installed successfully!"
}

# Function to install Plex Media Server on Fedora
install_plex_fedora() {
    echo "Installing Plex Media Server on Fedora..."
    sudo dnf install plexmediaserver -y
    sudo systemctl enable plexmediaserver
    sudo systemctl start plexmediaserver
    echo "Plex Media Server installed successfully!"
}

# Detect the Linux distribution and call the appropriate installation function
if [[ -f /etc/lsb-release ]]; then
    # Ubuntu/Debian
    install_plex_ubuntu
elif [[ -f /etc/redhat-release ]]; then
    if grep -qi "centos" /etc/redhat-release; then
        # CentOS/RHEL
        install_plex_centos
    elif grep -qi "fedora" /etc/redhat-release; then
        # Fedora
        install_plex_fedora
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
else
    echo "Unsupported Linux distribution."
    exit 1
fi
