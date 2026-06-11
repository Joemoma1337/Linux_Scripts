import sys
import re
from datetime import timedelta
from charset_normalizer import detect
from pathlib import Path

# Pre-compile regex for speed; match directly at the start of the line if possible
TIMESTAMP_PATTERN = re.compile(r"^(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})")

def parse_and_adjust(match, delta_ms):
    """
    Directly converts extracted regex string groups into milliseconds,
    applies the offset mathematically, and formats back to string.
    Bypasses costly datetime object creation.
    """
    h1, m1, s1, ms1, h2, m2, s2, ms2 = map(int, match.groups())
    
    # Convert timestamps completely to absolute milliseconds
    start_ms = ((h1 * 3600 + m1 * 60 + s1) * 1000) + ms1
    end_ms = ((h2 * 3600 + m2 * 60 + s2) * 1000) + ms2
    
    # Apply offset
    new_start = max(0, start_ms + delta_ms)
    new_end = max(0, end_ms + delta_ms)
    
    # Helper to reformat ms back to SRT format
    def format_ms(total_ms):
        ms = total_ms % 1000
        total_seconds = total_ms // 1000
        s = total_seconds % 60
        total_minutes = total_seconds // 60
        m = total_minutes % 60
        h = total_minutes // 60
        return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

    return f"{format_ms(new_start)} --> {format_ms(new_end)}"

def process_srt(input_path, adjustment_seconds):
    path = Path(input_path)
    
    if not path.exists():
        print(f"Error: File '{input_path}' not found.", file=sys.stderr)
        return

    # 1. Efficiently read raw data and detect encoding
    raw_data = path.read_bytes()
    if not raw_data:
        print(f"Error: File '{input_path}' is empty.", file=sys.stderr)
        return
        
    detection = detect(raw_data)
    encoding = detection["encoding"] or "utf-8"
    
    # 2. Convert adjustment seconds to an integer of total milliseconds
    delta_ms = int(adjustment_seconds * 1000)
    
    # 3. Process lines using a fast list comprehension / generator hybrid
    lines = raw_data.decode(encoding).splitlines()
    adjusted_lines = []
    
    for line in lines:
        match = TIMESTAMP_PATTERN.match(line)
        if match:
            adjusted_lines.append(parse_and_adjust(match, delta_ms))
        else:
            adjusted_lines.append(line)

    # 4. Save file efficiently (Standard SRT specs use CRLF or LF; preserve modern defaults)
    output_path = path.with_name(f"{path.stem}_adjusted{path.suffix}")
    output_path.write_text("\n".join(adjusted_lines), encoding="utf-8")
    print(f"Success! Adjusted file saved to: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python script.py <path_to_srt> <seconds_to_adjust>")
        print("Example: python script.py movie.srt 1.5")
    else:
        file_arg = sys.argv[1]
        try:
            time_arg = float(sys.argv[2])
            process_srt(file_arg, time_arg)
        except ValueError:
            print("Error: The adjustment value must be a number (e.g., 14 or -5.2).", file=sys.stderr)
