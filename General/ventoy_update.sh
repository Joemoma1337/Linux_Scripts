#!/bin/bash

# --- Script Safety ---
set -euo pipefail

# --- Configuration ---
MOUNT_DIR="/mnt/ventoy_update"
# Cleanup function to run on exit (even on errors)
cleanup() {
    echo "--- Cleaning up ---"
    if mountpoint -q "$MOUNT_DIR"; then
        sudo umount "$MOUNT_DIR"
    fi
    if [[ -n "${ventoy_loop:-}" ]]; then
        sudo losetup -d "$ventoy_loop" 2>/dev/null || true
    fi
}
trap cleanup EXIT

# 1. Gather Info
# Try to find ventoy.img in the local directory first
DEFAULT_IMG=$(find . -maxdepth 1 -name "ventoy.img" | head -n 1)
read -p "Path to ventoy.img [Default: $DEFAULT_IMG]: " VENTOY_IMG
VENTOY_IMG="${VENTOY_IMG:-$DEFAULT_IMG}"

if [[ ! -f "$VENTOY_IMG" ]]; then
    echo "Error: File '$VENTOY_IMG' not found."
    exit 1
fi

read -p "Enter PiKVM IP address: " PiKVMIP
read -p "Path to directory containing new files: " new_files_dir

if [[ ! -d "$new_files_dir" ]]; then
    echo "Error: Directory '$new_files_dir' not found."
    exit 1
fi

# 2. Mounting Logic
echo "===== Mounting ventoy.img ====="
sudo mkdir -p "$MOUNT_DIR"
ventoy_loop=$(sudo losetup -P -f --show "$VENTOY_IMG")

# Use udevadm to ensure the partition nodes (p1, p2) are created before mounting
sudo udevadm settle

if ! sudo mount "${ventoy_loop}p1" "$MOUNT_DIR"; then
    echo "Failed to mount partition 1."
    exit 1
fi

# 3. Smart Syncing
echo "===== Syncing files ====="
# rsync -av --delete will make the .img an EXACT match of your source folder
# Remove --delete if you want to keep old files already in the .img
sudo rsync -avh --progress "$new_files_dir/" "$MOUNT_DIR/"

# 4. Finalize Image
echo "===== Unmounting and Detaching ====="
sudo umount "$MOUNT_DIR"
sudo losetup -d "$ventoy_loop"
# Clear the variable so the trap doesn't try to delete it again
ventoy_loop="" 

# 5. Remote Transfer to PiKVM
echo "===== Transferring to PiKVM ====="
# Remount PiKVM storage as read-write, transfer, then back to read-only
# This assumes you are using the default PiKVM mass storage path
PIKVM_STORAGE="/var/lib/kvmd/msd"

ssh root@"$PiKVMIP" "mount -o remount,rw $PIKVM_STORAGE"
scp "$VENTOY_IMG" root@"$PiKVMIP":"$PIKVM_STORAGE/ventoy.img"
ssh root@"$PiKVMIP" "touch $PIKVM_STORAGE/.__ventoy.img.complete && mount -o remount,ro $PIKVM_STORAGE"

echo "Update and Transfer completed successfully!"
