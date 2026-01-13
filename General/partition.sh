#!/bin/bash

# --- Script Configuration and Safety ---
set -euo pipefail

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Functions ---
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $1" >&2; }

unmount_drive_partitions() {
    local drive_path="$1"
    log_info "Checking for active mounts on $drive_path..."
    
    # findmnt is more robust than parsing lsblk for this specific task
    local mount_points
    mount_points=$(findmnt -rnlo TARGET --source "$drive_path" || true)
    
    if [[ -n "$mount_points" ]]; then
        log_warn "Unmounting active partitions..."
        # Unmount recursively to handle nested mounts
        umount -R "$drive_path" || { log_err "Failed to unmount. Is a file open?"; exit 1; }
    fi
}

# --- Main Script Logic ---

# 1. Enhanced Disk Display
echo -e "${YELLOW}Available Physical Disks:${NC}"
lsblk -dno NAME,SIZE,MODEL | grep -v 'loop'
echo

read -p "Enter the drive name (e.g., sdb or nvme0n1): " drive
read -p "Enter format (ext4, fat32, ntfs): " format
read -p "Enter label: " name

# 2. Dynamic Path Validation
drive_path="/dev/${drive%/}" # Strip trailing slashes if user included them
if [[ ! -b "$drive_path" ]]; then
    log_err "Device $drive_path not found."; exit 1
fi

# Root Protection using 'lsblk' to find the actual disk containing /
root_disk="/dev/$(lsblk -no PKNAME $(findmnt -nvo SOURCE /))"
if [[ "$drive_path" == "$root_disk"* ]]; then
    log_err "SECURITY ALERT: $drive_path appears to be part of the OS drive! Exiting."; exit 1
fi

# 3. Cleanup and Confirmation
unmount_drive_partitions "$drive_path"

echo -e "${RED}!!! WARNING: ALL DATA ON $drive_path WILL BE PERMANENTLY DELETED !!!${NC}"
read -p "Type 'CONFIRM' to proceed: " final_check
if [[ "$final_check" != "CONFIRM" ]]; then
    log_info "Operation aborted."; exit 0
fi

# 4. Partitioning
log_info "Wiping existing signatures and creating GPT partition table..."
wipefs -a "$drive_path"

# mklabel gpt is better for modern systems/large drives
parted -s -a optimal "$drive_path" mklabel gpt mkpart primary "$format" 0% 100%

# Update kernel partition table
udevadm settle # Wait for system to process device changes
partprobe "$drive_path"

# 5. Smart Partition Path Detection
# Handles both /dev/sdb1 and /dev/nvme0n1p1
if [[ "$drive_path" =~ "nvme" ]]; then
    partition_path="${drive_path}p1"
else
    partition_path="${drive_path}1"
fi

# 6. Formatting
log_info "Formatting $partition_path as $format..."
case "$format" in
    ext4)  mkfs.ext4 -L "$name" -F "$partition_path" ;;
    fat32) mkfs.fat -F 32 -n "$name" "$partition_path" ;;
    ntfs)  mkfs.ntfs -f -L "$name" "$partition_path" ;;
    *)     log_err "Unsupported format."; exit 1 ;;
esac

log_info "Finalizing..."
udevadm settle

echo -e "\n${GREEN}===== Partitioning Complete! =====${NC}"
lsblk -f "$drive_path"
