#!/bin/bash
# Function to compare version numbers
version_compare() {
    if [[ "$1" == "$2" ]]; then
        return 0  # versions are equal
    fi
    local IFS=.
    local i version1=($1) version2=($2)
    # Fill empty fields in version numbers with zeros
    for ((i=${#version1[@]}; i<${#version2[@]}; i++)); do
        version1[i]=0
    done
    for ((i=0; i<${#version1[@]}; i++)); do
        if [[ -z "${version2[i]}" ]]; then
            version2[i]=0
        fi
        if ((10#${version1[i]} > 10#${version2[i]})); then
            return 1  # version1 is greater
        fi
        if ((10#${version1[i]} < 10#${version2[i]})); then
            return 2  # version2 is greater
        fi
    done
    return 0  # versions are equal
}
# Check if Plex is installed
if ! command -v plexmediaserver &> /dev/null; then
    echo "Plex is not installed. Installing..."
    # Add your installation commands here
    # For example: sudo apt-get install -y plexmediaserver
else
    # Plex is installed, check versions
    installed_version=$(dpkg-query -f '${Version}' -W plexmediaserver 2>/dev/null)
    latest_version=$(curl -s https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64 | grep -oP '(\d+\.\d+\.\d+\.\d+)')
    
    version_compare "$installed_version" "$latest_version"
    compare_result=$?
    if [ $compare_result -eq 0 ] || [ $compare_result -eq 1 ]; then
        echo "Plex is up to date. Installed version: $installed_version"
    else
        echo "Updating Plex to version $latest_version..."
        # Add your update commands here
        # For example: sudo apt-get install -y --only-upgrade plexmediaserver
    fi
fi
