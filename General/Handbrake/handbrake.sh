#!/bin/bash

WATCH_DIR="/home/standard/Downloads/test1"
OUTPUT_DIR="/home/standard/Downloads/test2"

while true; do
  # Wait for new files to be added to the watch directory
  inotifywait -e create "$WATCH_DIR"

  # Process all newly added files
  for INPUT_FILE in "$WATCH_DIR"/*.mkv "$WATCH_DIR"/*.avi "$WATCH_DIR"/*.mp4; do
    if [[ -f "$INPUT_FILE" ]]; then
      # Generate output file name
      OUTPUT_FILE="$OUTPUT_DIR/$(basename "${INPUT_FILE%.*}").mp4"

      # Convert the video using HandBrakeCLI
      HandBrakeCLI --preset-import-file /home/standard/Downloads/h264_FR30_RF20.json -Z "h264_FR30_RF20" -i "$INPUT_FILE" -o "$OUTPUT_FILE"

      # Remove the input file
      rm "$INPUT_FILE"
    fi
  done
done
