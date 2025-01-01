#!/bin/bash
# Define variables
MODULES_DIR="vmware-host-modules"
ORIGINAL_DIR="VMWare_host_modules_original"
VERSION="workstation-17.5.1"

# Remove the existing vmware-host-modules directory (with confirmation)
if [ -d "$MODULES_DIR" ]; then
    echo "Removing existing $MODULES_DIR directory..."
    rm -rf "$MODULES_DIR" || { echo "Failed to remove $MODULES_DIR. Exiting."; exit 1; }
fi

# Copy the original modules directory
if [ -d "$ORIGINAL_DIR" ]; then
    echo "Copying $ORIGINAL_DIR to $MODULES_DIR..."
    cp -r "$ORIGINAL_DIR/" "$MODULES_DIR" || { echo "Failed to copy $ORIGINAL_DIR. Exiting."; exit 1; }
else
    echo "Error: $ORIGINAL_DIR does not exist. Exiting."
    exit 1
fi

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
