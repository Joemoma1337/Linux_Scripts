import sys
import re
from datetime import timedelta, datetime
from charset_normalizer import detect
from pathlib import Path

def adjust_timestamp(timestamp, delta):
    """Adjust a single timestamp with a floor at 00:00:00."""
    timestamp_format = "%H:%M:%S,%f"
    time_obj = datetime.strptime(timestamp, timestamp_format)
    
    # Calculate new time
    new_time = time_obj + delta
    
    # Ensure we don't go into negative time
    zero_time = datetime.strptime("00:00:00,000", timestamp_format)
    if new_time < zero_time:
        return "00:00:00,000"
    
    return new_time.strftime(timestamp_format)[:-3]

def process_srt(input_path, adjustment_seconds):
    path = Path(input_path)
    
    if not path.exists():
        print(f"Error: File '{input_path}' not found.")
        return

    # Detect encoding
    raw_data = path.read_bytes()
    detection = detect(raw_data)
    encoding = detection["encoding"] or "utf-8"
    
    # Prepare output filename (e.g., movie.srt -> movie_adjusted.srt)
    output_path = path.with_name(f"{path.stem}_adjusted{path.suffix}")
    
    delta = timedelta(seconds=adjustment_seconds)
    timestamp_pattern = re.compile(r"(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})")
    
    lines = raw_data.decode(encoding).splitlines()
    adjusted_lines = []

    for line in lines:
        match = timestamp_pattern.search(line)
        if match:
            start, end = match.groups()
            adjusted_lines.append(f"{adjust_timestamp(start, delta)} --> {adjust_timestamp(end, delta)}")
        else:
            adjusted_lines.append(line)

    output_path.write_text("\n".join(adjusted_lines), encoding="utf-8")
    print(f"Success! Adjusted file saved to: {output_path}")

if __name__ == "__main__":
    # Check if user provided arguments: [script.py, file_path, seconds]
    if len(sys.argv) < 3:
        print("Usage: python script.py <path_to_srt> <seconds_to_adjust>")
        print("Example: python script.py movie.srt 1.5")
    else:
        file_arg = sys.argv[1]
        try:
            time_arg = float(sys.argv[2])
            process_srt(file_arg, time_arg)
        except ValueError:
            print("Error: The adjustment value must be a number (e.g., 14 or -5.2).")
