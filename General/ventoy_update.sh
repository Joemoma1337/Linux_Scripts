#!/bin/bash

# Define variables
VENTOY_IMG="/home/standard/Ventoy/ventoy.img"  # Adjust path to your ventoy.img file
MOUNT_DIR="/mnt/ventoy"
#PiKVMIP="192.168.1.100"  # Replace with your PiKVM IP address

# Mount ventoy.img to a temporary directory
echo "===== Mounting ventoy.img ====="
sudo mkdir -p "$MOUNT_DIR"

# Use losetup to find the loop device associated with ventoy.img
ventoy_loop=$(sudo losetup -P -f --show "$VENTOY_IMG")
if [ -z "$ventoy_loop" ]; then
    echo "Failed to set up loop device for $VENTOY_IMG"
    exit 1
fi

# Check the partitions available
lsblk "$ventoy_loop"

# Mount the first partition of the ventoy.img
sudo mount "${ventoy_loop}p1" "$MOUNT_DIR"

if ! mountpoint -q "$MOUNT_DIR"; then
    echo "Failed to mount ${ventoy_loop}p1 to $MOUNT_DIR"
    sudo losetup -d "$ventoy_loop"
    exit 1
fi

# Copy new files into ventoy.img
echo "===== Copying new files ====="
read -p 'Full path to directory containing new files (ex: /path/to/new/files): ' new_files_dir

sudo cp -rv "$new_files_dir"/* "$MOUNT_DIR"

# Unmount ventoy.img
echo "===== Unmounting ventoy.img ====="
sudo umount "$MOUNT_DIR"

# Clean up loop device
sudo losetup -d "$ventoy_loop"

# Transfer updated ventoy.img to PiKVM
echo "===== Transferring ventoy.img to PiKVM ====="
#scp -v "$VENTOY_IMG" standard@"$PiKVMIP":/home/standard

echo "Script completed successfully"
