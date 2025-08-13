#!/bin/bash

# --- Script Configuration and Safety ---
set -euo pipefail

# --- Functions ---
# Safely unmount all partitions on a given drive.
# This function is crucial for preventing a "device is busy" error.
unmount_drive_partitions() {
    local drive_path="$1"
    local drive_name="${drive_path#/dev/}"
    local mount_points
    mount_points=$(lsblk -o MOUNTPOINT,NAME -n "$drive_path" | awk '$1!="" {print $1}')
    
    if [[ -z "$mount_points" ]]; then
        echo "No partitions to unmount on $drive_name."
        return 0
    fi
    
    echo "Unmounting the following mount points on $drive_name:"
    echo "$mount_points"
    
    # Use xargs to safely handle multiple mount points
    if ! echo "$mount_points" | xargs -r umount -f; then
        echo "Error: Failed to unmount all partitions on $drive_name." >&2
        echo "Please check for active processes using the device and try again." >&2
        exit 1
    fi
}

# --- Main Script Logic ---
# 1. Display available drives and their sizes.
echo "Available drives for partitioning:"
lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep 'disk' | grep -v 'loop'

echo
read -p "Enter the drive to partition (e.g., sdb): " drive
read -p "Enter the filesystem format (ext4, fat32, ntfs): " format
read -p "Enter the new drive label (e.g., 16gb): " name

# 2. Input Validation and Security Checks (CRITICAL)
if [[ ! "$drive" =~ ^sd[a-z]+$ ]]; then
    echo "Error: Invalid drive name '$drive'. Must be in 'sdX' format." >&2
    exit 1
fi
drive_path="/dev/$drive"

if [[ ! -b "$drive_path" ]]; then
    echo "Error: Drive '$drive_path' does not exist." >&2
    exit 1
fi

# Prevent accidentally wiping the root filesystem.
if mountpoint -q /; then
    root_device=$(df / | grep /dev | awk '{print $1}' | sed 's/[0-9]*$//')
    if [[ "$drive_path" == "$root_device" ]]; then
        echo "SECURITY WARNING: Cannot partition the root device '$root_device'." >&2
        echo "Exiting for your safety." >&2
        exit 1
    fi
fi

# 3. Unmount and Data Destruction Warning
unmount_drive_partitions "$drive_path"
echo "WARNING: All data on $drive_path will be erased."
read -r -p "Are you sure you want to continue? [y/N] " confirmation
if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Partitioning cancelled."
    exit 0
fi

# 4. Partitioning with Parted (more modern and reliable)
echo "Creating a single primary partition using parted..."
if ! parted -s -a optimal "$drive_path" mklabel msdos mkpart primary "$format" 0% 100%; then
    echo "Error: Failed to create partition with parted. Check disk for errors." >&2
    exit 1
fi

# Wait for the kernel to detect the new partition table.
partprobe "$drive_path"
sleep 2

# 5. Formatting the New Partition
partition_path="${drive_path}1"
if [[ ! -b "$partition_path" ]]; then
    echo "Error: Partition '$partition_path' not found after partitioning." >&2
    exit 1
fi

echo "Formatting $partition_path as $format with label '$name'..."
case "$format" in
    ext4)
        mkfs.ext4 -L "$name" -F "$partition_path"
        ;;
    fat32)
        mkfs.fat -F 32 -n "$name" "$partition_path"
        ;;
    ntfs)
        mkfs.ntfs -f -L "$name" "$partition_path"
        ;;
    *)
        echo "Internal Error: Format case block failed unexpectedly." >&2
        exit 1
        ;;
esac

# 6. Completion Message
echo ""
echo "===== Partitioning and Formatting Complete! ====="
echo "New partition: $partition_path"
echo "Filesystem: $format"
echo "Label: $name"
echo
