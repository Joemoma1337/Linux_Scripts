#!/bin/bash

# Display available drives
lsblk | grep sd | awk '{print $1, $4, $7}'
echo ""

# Prompt user for inputs
read -p "Enter drive (example: sdb): " drive
read -p "Enter format (example: ext4, fat32, ntfs): " format
read -p "Enter new drive name (example: 16gb): " name

drive_path="/dev/$drive"

# Check if the drive exists
if [[ ! -b $drive_path ]]; then
    echo "Error: Drive $drive_path does not exist."
    exit 1
fi

# Unmount existing partitions on the drive
mount_point=$(lsblk | grep "$drive" | awk '{print $7}' | grep -v "" | head -n 1)
if [[ -n $mount_point ]]; then
    echo "Unmounting $mount_point..."
    umount "$mount_point"
fi

# Wipe existing filesystem
echo "Wiping filesystem on ${drive_path}1..."
wipefs -a "${drive_path}1"

# Create a new partition
echo "Creating a new partition on $drive_path..."
echo ';' | sfdisk "$drive_path"

# Format the partition and set the label
partition_path="${drive_path}1"
echo "Formatting $partition_path as $format..."
case $format in
    fat32)
        echo y | mkfs.fat "$partition_path"
        fatlabel "$partition_path" "$name"
        ;;
    ext4)
        echo y | mkfs.ext4 "$partition_path"
        e2label "$partition_path" "$name"
        ;;
    ntfs)
        echo y | mkfs.ntfs -f "$partition_path"
        ntfslabel "$partition_path" "$name"
        ;;
    *)
        echo "Error: Unsupported format $format."
        exit 1
        ;;
esac

# Completion message
echo ""
echo "===== Partitioning Complete! ====="

# Additional instructions for creating Windows 10 bootable media
# To create Windows 10 bootable:
# - Mount Windows 10 ISO and USB after partitioning
# - Copy the contents of the ISO to the new partition
