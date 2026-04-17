#!/bin/bash

INPUT="Input.mp3"
# Format: "Timestamp Title"
TRACKS=(
"0:00 Track1"
"2:40 TrackTwo"
"4:55 Track 3"
"10:09 Track Four"
"15:53 Track5"
"16:58 Track6"
"20:58 Track7"
"23:43 Track8"
"30:28 Track9"
"33:36 Track10"
)

for i in "${!TRACKS[@]}"; do
    # Extract start time and title
    START=$(echo "${TRACKS[$i]}" | cut -d' ' -f1)
    TITLE=$(echo "${TRACKS[$i]}" | cut -d' ' -f2-)
    
    # Define output filename (replacing spaces with underscores)
    OUT_FILE="${TITLE// /_}.mp3"
    
    # Get the start time of the NEXT track to find the end time
    NEXT_INDEX=$((i + 1))
    if [ $NEXT_INDEX -lt ${#TRACKS[@]} ]; then
        END=$(echo "${TRACKS[$NEXT_INDEX]}" | cut -d' ' -f1)
        echo "Processing: $TITLE [$START to $END]"
        ffmpeg -i "$INPUT" -ss "$START" -to "$END" -c copy "$OUT_FILE" -loglevel error
    else
        # For the last track, just go to the end of the file
        echo "Processing: $TITLE [$START to end]"
        ffmpeg -i "$INPUT" -ss "$START" -c copy "$OUT_FILE" -loglevel error
    fi
done

echo "Done! All tracks have been split."
