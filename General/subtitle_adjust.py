import re
from datetime import timedelta, datetime
from charset_normalizer import detect
from pathlib import Path

def adjust_timestamp(timestamp, delta):
    """Adjust a single timestamp by a time delta."""
    timestamp_format = "%H:%M:%S,%f"
    time_obj = datetime.strptime(timestamp, timestamp_format)
    adjusted_time = time_obj + delta
    return adjusted_time.strftime(timestamp_format)[:-3]  # Format back to SRT style

def adjust_srt_file(input_file, output_file, time_adjustment):
    """Adjust timestamps in an SRT file."""
    delta = timedelta(seconds=time_adjustment)
    timestamp_pattern = re.compile(r"(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})")
    
    # Detect the file's encoding
    with open(input_file, "rb") as f:
        raw_data = f.read()
    encoding = detect(raw_data)["encoding"]
    
    if not encoding:
        raise ValueError("Could not detect the file's encoding.")

    # Decode the file with the detected encoding
    decoded_data = raw_data.decode(encoding)
    
    # Process and adjust the timestamps
    with open(output_file, "w", encoding="utf-8") as outfile:
        for line in decoded_data.splitlines():
            match = timestamp_pattern.search(line)
            if match:
                start_time, end_time = match.groups()
                new_start_time = adjust_timestamp(start_time, delta)
                new_end_time = adjust_timestamp(end_time, delta)
                outfile.write(f"{new_start_time} --> {new_end_time}\n")
            else:
                outfile.write(line + "\n")

# Example usage
Dir = Path("/path/to/folder")
input_file = Dir / "original.srt"
output_file = Dir / "new.output.srt"
time_adjustment = 14
adjust_srt_file(input_file, output_file, time_adjustment)






