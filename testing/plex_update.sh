#!/bin/bash
version=$(curl "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"| cut -d '/' -f 7 | cut -d '"' -f 1)
# Download the latest Plex Media Server package for Ubuntu 64-bit
wget -O $version "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"
# Install the package
sudo dpkg -i $version
# Clean up the downloaded package
#rm ~/plexmediaserver.deb
