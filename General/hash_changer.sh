#!/bin/bash

TARGET_DIR="${1:-.}"

# Find mp4, mkv, and txt files
find "$TARGET_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.txt" \) | while read -r file; do
    
    if [[ "$file" == *.txt ]]; then
        # For text files, just add a space to the end
        echo -n " " >> "$file"
        echo "Modified (Text): $file"
    else
        # For video files, use the truncate method (adds 1 null byte)
        size=$(stat -c%s "$file")
        truncate -s $((size + 1)) "$file"
        echo "Modified (Video): $file"
    fi
done
