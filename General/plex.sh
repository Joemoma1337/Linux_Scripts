#!/bin/bash
currentinstalled=$(dpkg -s plexmediaserver|grep Version|cut -d ' ' -f2)
version=$(curl "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu"|grep 'Release id'|cut -d '"' -f4)
latesturl=$(curl "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu"|grep 'url='|cut -d '"' -f18)

if [ -z "$currentinstalled" ]; then
  # currentinstalled is empty, Download the latest Plex Media Server package for Ubuntu 64-bit
        wget -O "plexmediaserver_"$version"_amd64.deb" "$latesturl"
        # Install the package
        sudo dpkg -i $version
elif [[ "$currentinstalled" > "$version" ]]; then
  # currentinstalled is greater than version, do nothing
  :
elif [[ "$currentinstalled" < "$version" ]]; then
  # currentinstalled is less than version, Download the latest Plex Media Server package for Ubuntu 64-bit
        wget -O $version "$latesturl"
        # Install the package
        sudo dpkg -i $version
else
  # currentinstalled is equal to plexlatest, do nothing
         echo "===== Already up to date ====="
fi
