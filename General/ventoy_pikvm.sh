#!/bin/bash
# --- Script Safety ---
set -euo pipefail

# --- Configuration & Vars ---
WORKING_DIR="$HOME/Ventoy"
MOUNT_POINT="/media/ventoy"
PIKVM_DEST="/var/lib/kvmd/msd"

# Helper for colorful logs
log() { echo -e "\033[1;32m[ $(date +%T) ] $1\033[0m"; }

# 1. Prepare Directory
log "Setting up working directory..."
[[ ! -d "$WORKING_DIR" ]] && mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

# 2. Dynamic Version Fetching (Optional but recommended)
# Fetches the latest version string from GitHub API
log "Checking for latest Ventoy version..."
LATEST_VER=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
TAR_FILE="ventoy-${LATEST_VER}-linux.tar.gz"
EXTRACTED_DIR="ventoy-${LATEST_VER}"

# 3. Download Ventoy
if [[ ! -f "$TAR_FILE" ]]; then
    log "Downloading Ventoy v$LATEST_VER..."
    wget "https://github.com/ventoy/Ventoy/releases/download/v${LATEST_VER}/${TAR_FILE}"
fi

if [[ ! -d "$EXTRACTED_DIR" ]]; then
    tar -zxvf "$TAR_FILE"
fi

# 4. Create Image
echo -n "What size do you want your ventoy.img to be (in GB)? " && read -r count
log "Creating ${count}GB image (this may take a minute)..."
dd if=/dev/zero of=ventoy.img bs=1M count=$((count * 1024)) status=progress

# 5. Loop Setup
log "Attaching loop device..."
# --show prints the device name (e.g., /dev/loop0) instantly
ventoy_loop=$(sudo losetup -fP --show ventoy.img)

# 6. Install Ventoy to Image
log "Installing Ventoy to $ventoy_loop..."
# -u enables non-interactive mode if needed
sudo sh "${EXTRACTED_DIR}/Ventoy2Disk.sh" -i "$ventoy_loop" -g -b

# 7. Mount and Copy ISOs
log "Mounting partition 1..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount "${ventoy_loop}p1" "$MOUNT_POINT"

echo -n "Full path to ISO directory (e.g., /home/pi/Downloads): " && read -r iso_dir
log "Copying files from $iso_dir..."
sudo cp -rv "$iso_dir"/* "$MOUNT_POINT"

# 8. Cleanup Local Mounts
log "Cleaning up local mounts..."
sudo umount "$MOUNT_POINT"
sudo losetup -d "$ventoy_loop"

# 9. Transfer to PiKVM
echo -n "Enter PiKVM IP Address: " && read -r PiKVMIP
log "Transferring to PiKVM at $PiKVMIP..."

# Using a single SSH block for efficiency
ssh root@"$PiKVMIP" "mount -o remount,rw $PIKVM_DEST"
scp -v ventoy.img root@"$PiKVMIP":"$PIKVM_DEST/"
ssh root@"$PiKVMIP" "touch $PIKVM_DEST/.__ventoy.img.complete && mount -o remount,ro $PIKVM_DEST"

log "===== Process Complete ====="
