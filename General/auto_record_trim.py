import os
import subprocess

# Paths
videos_lst = "videos.lst"
videos_dir = "/Path/to/Source/to.be.trimmed"
output_dir = "/Path/to/Destination/Backup"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Read the list of videos and durations
with open(videos_lst, 'r') as file:
    lines = file.readlines()

# Process each line in videos.lst
for line in lines:
    # Extract video name and duration
    video_name, duration = line.strip().split("\t")
    video_file = os.path.join(videos_dir, f"{video_name}.mp4")

    # Check if the video file exists
    if os.path.isfile(video_file):
        # Convert duration to seconds (ffmpeg requires this format)
        minutes, seconds = map(int, duration.split(":"))
        total_seconds = minutes * 60 + seconds

        # Output file path
        output_file = os.path.join(output_dir, f"{video_name}.mp4")

        # Run ffmpeg to trim the video
        ffmpeg_command = [
            "ffmpeg",
            "-i", video_file,
            "-t", str(total_seconds),
            "-c", "copy",  # Copy codec to avoid re-encoding
            output_file
        ]

        subprocess.run(ffmpeg_command)
        print(f"Trimmed and saved: {output_file}")
    else:
        print(f"Video file not found: {video_file}")
