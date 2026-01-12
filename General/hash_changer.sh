#!/bin/bash

# Ensure exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "Error: exiftool is not installed. Install it with 'sudo apt install libimage-exiftool-perl'"
    exit 1
fi

LOG_FILE="metadata_hash_log.txt"
EXTENSIONS=("docx" "mov" "mp4" "mp3" "txt")

echo "Starting Metadata Hash Modification..."
echo "Log: $LOG_FILE"

for ext in "${EXTENSIONS[@]}"; do
    find . -maxdepth 1 -iname "*.$ext" -type f | while read -r file; do
        
        old_hash=$(md5sum "$file" | awk '{ print $1 }')
        
        # Generate a random string to ensure a unique hash
        rand_id=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

        if [[ "$ext" == "txt" ]]; then
            # TXT files don't have metadata headers. 
            # We add a hidden comment line at the top instead.
            sed -i "1s/^/# ID:$rand_id\n/" "$file"
        else
            # For docx, mov, mp4, mp3:
            # -overwrite_original prevents exiftool from creating ._original backups
            # -Comment adds/updates the comment field in the metadata
            exiftool -overwrite_original -Comment="RefID-$rand_id" "$file" > /dev/null
        fi

        new_hash=$(md5sum "$file" | awk '{ print $1 }')
        echo "Processed $file: $old_hash -> $new_hash" | tee -a "$LOG_FILE"
    done
done
