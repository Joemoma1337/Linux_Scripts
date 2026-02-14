import datetime
import argparse
import sys

def adjust_srt_time(time_str, offset_seconds):
    """
    Adjusts an SRT timestamp by a given offset in seconds.
    Format: HH:MM:SS,mmm
    """
    # SRT uses commas for decimals; Python's strptime prefers dots
    time_format = "%H:%M:%S,%f"
    
    try:
        # Convert string to datetime object
        t = datetime.datetime.strptime(time_str, time_format)
        
        # Apply the offset using a timedelta
        delta = datetime.timedelta(seconds=offset_seconds)
        adjusted = t + delta
        
        # Prevent the time from going before 00:00:00,000
        if adjusted.year < 1900:
            return "00:00:00,000"
            
        # Format back to SRT string (truncating microseconds to milliseconds)
        return adjusted.strftime(time_format)[:-3]
    except ValueError:
        return time_str

def process_file(input_path, output_path, offset):
    try:
        with open(input_path, 'r', encoding='utf-8') as f_in, \
             open(output_path, 'w', encoding='utf-8') as f_out:
            
            for line in f_in:
                # Check if the line is a timestamp line (contains the arrow separator)
                if " --> " in line:
                    parts = line.strip().split(" --> ")
                    if len(parts) == 2:
                        start = adjust_srt_time(parts[0], offset)
                        end = adjust_srt_time(parts[1], offset)
                        f_out.write(f"{start} --> {end}\n")
                    else:
                        f_out.write(line)
                else:
                    f_out.write(line)
        print(f"Successfully created: {output_path}")
    except FileNotFoundError:
        print(f"Error: The file '{input_path}' was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Shift SRT subtitle timestamps.")
    parser.add_argument("input", help="The input .srt file")
    parser.add_argument("offset", type=float, help="Offset in seconds (e.g., -0.5 or 1.2)")
    parser.add_argument("-o", "--output", help="Output file name (default: adjusted_input.srt)")
#python3 adjust_subs.py [filename] [offset]
    args = parser.parse_args()
    
    output_file = args.output if args.output else f"adjusted_{args.input}"
    process_file(args.input, output_file, args.offset)
