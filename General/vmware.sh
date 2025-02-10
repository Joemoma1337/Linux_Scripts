#!/bin/bash
# Define variables
MODULES_DIR="vmware-host-modules"
ORIGINAL_DIR="VMWare_host_modules_original"
VERSION=$(vmware -v 2>/dev/null | grep -oP '\d+\.\d+\.\d+')  # Get the installed VMware version

# Check if the VERSION is successfully retrieved
if [ -z "$VERSION" ]; then
    echo "Error: VMware Workstation version not found. Exiting."
    exit 1
fi

echo "Detected VMware version: $VERSION"

# Check if the original directory exists
if [ ! -d "$ORIGINAL_DIR" ]; then
    echo "$ORIGINAL_DIR does not exist. Cloning from Git..."
    git clone https://github.com/bytium/vm-host-modules.git "$ORIGINAL_DIR" || { echo "Failed to clone $ORIGINAL_DIR. Exiting."; exit 1; }
else
    echo "$ORIGINAL_DIR already exists. Skipping download."
fi

# Remove the existing vmware-host-modules directory (with confirmation)
if [ -d "$MODULES_DIR" ]; then
    echo "Removing existing $MODULES_DIR directory..."
    rm -rf "$MODULES_DIR" || { echo "Failed to remove $MODULES_DIR. Exiting."; exit 1; }
fi

# Copy the original modules directory
echo "Copying $ORIGINAL_DIR to $MODULES_DIR..."
cp -r "$ORIGINAL_DIR/" "$MODULES_DIR" || { echo "Failed to copy $ORIGINAL_DIR. Exiting."; exit 1; }

# Navigate to the vmware-host-modules directory
cd "$MODULES_DIR" || { echo "Failed to change to $MODULES_DIR. Exiting."; exit 1; }

# Checkout the specified version
if git checkout "$VERSION"; then
    echo "Checked out version $VERSION."
else
    echo "Error: Failed to checkout version $VERSION. Exiting."
    exit 1
fi

# Build the modules
if sudo make; then
    echo "Build successful."
else
    echo "Error: Build failed. Exiting."
    exit 1
fi

# Install the modules
if sudo make install; then
    echo "Installation successful."
else
    echo "Error: Installation failed. Exiting."
    exit 1
fi

# Confirm before rebooting
read -p "Do you want to reboot now? (y/n): " choice
if [[ "$choice" == [Yy] ]]; then
    echo "Rebooting..."
    sudo reboot
else
    echo "Reboot skipped. Please reboot manually if necessary."
fi
