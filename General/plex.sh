#!/bin/bash
currentinstalled=$(dpkg -s plexmediaserver|grep Version|cut -d ' ' -f2)
plexlatest=$(curl "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"| cut -d '/' -f5)
version=$(curl "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"| cut -d '/' -f 7 | cut -d '"' -f 1)

if [ -z "$currentinstalled" ]; then
  # currentinstalled is empty, Download the latest Plex Media Server package for Ubuntu 64-bit
        wget -O $version "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"
        # Install the package
        sudo dpkg -i $version
elif [[ "$currentinstalled" > "$plexlatest" ]]; then
  # currentinstalled is greater than plexlatest, do nothing
  :
elif [[ "$currentinstalled" < "$plexlatest" ]]; then
  # currentinstalled is less than plexlatest, Download the latest Plex Media Server package for Ubuntu 64-bit
        wget -O $version "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu"
        # Install the package
        sudo dpkg -i $version
