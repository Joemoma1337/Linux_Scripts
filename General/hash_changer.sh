#!/bin/bash

# Define the target directory (default is current directory)
TARGET_DIR="${1:-.}"

echo "Starting hash modification in: $TARGET_DIR"
echo "------------------------------------------"

# Find .mp4 and .mkv files and append 1 byte to each
find "$TARGET_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" \) | while read -r file; do
    # Get current file size
    size=$(stat -c%s "$file")
    
    # Increase size by 1 byte
    new_size=$((size + 1))
    
    # Use truncate to add a null byte at the end
    if truncate -s "$new_size" "$file"; then
        echo "Modified: $file"
    else
        echo "Error modifying: $file"
    fi
done

echo "------------------------------------------"
echo "Done! All file hashes have been changed."
