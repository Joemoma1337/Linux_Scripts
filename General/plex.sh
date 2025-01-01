#!/bin/bash
# Get the currently installed Plex Media Server version
currentinstalled=$(dpkg-query -W -f='${Version}' plexmediaserver 2>/dev/null)

# Fetch the latest version details
latest_details=$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu")
version=$(echo "$latest_details" | grep 'Release id' | cut -d '"' -f4)
latesturl=$(echo "$latest_details" | grep 'url=' | cut -d '"' -f18)

# Check if `curl` succeeded
if [ -z "$version" ] || [ -z "$latesturl" ]; then
    echo "Error: Unable to fetch latest Plex Media Server details."
    exit 1
fi

# Compare versions and update if needed
if [ -z "$currentinstalled" ]; then
    echo "Plex Media Server is not installed. Installing the latest version..."
    wget -q -O "plexmediaserver_${version}_amd64.deb" "$latesturl" || { echo "Download failed."; exit 1; }
    sudo dpkg -i "plexmediaserver_${version}_amd64.deb" || { echo "Installation failed."; exit 1; }
elif dpkg --compare-versions "$currentinstalled" lt "$version"; then
    echo "Updating Plex Media Server from version $currentinstalled to $version..."
    wget -q -O "plexmediaserver_${version}_amd64.deb" "$latesturl" || { echo "Download failed."; exit 1; }
    sudo dpkg -i "plexmediaserver_${version}_amd64.deb" || { echo "Installation failed."; exit 1; }
elif dpkg --compare-versions "$currentinstalled" eq "$version"; then
    echo "Plex Media Server is already up-to-date (version $version)."
else
    echo "Error: Installed version ($currentinstalled) is newer than the latest available version ($version)."
fi
