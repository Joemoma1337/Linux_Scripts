#!/bin/bash

# Prompt for the ventoy.img path
read -p "===== ventoy.img =====
Specify path to ventoy.img (ex: /home/ubuntu/Ventoy/ventoy.img): " ventoy_dir

# Set up loop device for ventoy.img
echo "===== losetup ====="
sudo losetup -f "$ventoy_dir"
ventoy_loop=$(losetup -j "$ventoy_dir" | awk -F: '{print $1}')

if [ -z "$ventoy_loop" ]; then
    echo "Failed to set up loop device"
    exit 1
fi

# Mount ventoy.img to directory
echo "===== mount ====="
mount_dir="/media/ventoy"
sudo mkdir -p "$mount_dir"
sudo mount "${ventoy_loop}p1" "$mount_dir"

if ! mountpoint -q "$mount_dir"; then
    echo "Failed to mount ${ventoy_loop}p1 to $mount_dir"
    sudo losetup -d "$ventoy_loop"
    exit 1
fi

# Prompt for the directory to copy files from
read -p "===== copy =====
Full path to directory you wish to transfer ALL files from (ex: /home/ubuntu/Downloads): " iso_dir

# Copy files
sudo cp -v "$iso_dir"/* "$mount_dir"

# Cleanup
echo "===== cleanup ====="
sudo umount "$mount_dir"
sudo losetup -d "$ventoy_loop"
