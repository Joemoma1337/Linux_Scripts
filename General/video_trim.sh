#!/bin/bash

# Directory containing the videos
input_dir="/Path/To/Source/Need.to.be.Trimmed"
output_dir="/Path/To/Destination/Backup"

# Create the output directory if it doesn't exist
#mkdir -p "$output_dir"

# Loop through all video files in the input directory
for input in "$input_dir"/*.mp4; do
  # Get the base name of the file
  base_name=$(basename "$input")
  output="$output_dir/$base_name"

  # Get the duration of the video in seconds
  duration=$(ffprobe -i "$input" -show_entries format=duration -v quiet -of csv="p=0")

  # Calculate the new duration (original duration - 3 seconds)
  new_duration=$(echo "$duration - 5" | bc)

  # Trim the video
  ffmpeg -i "$input" -t "$new_duration" -c copy "$output"
done
