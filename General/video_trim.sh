import argparse
import glob
import os
import subprocess
import sys


def trim_video(input_path, output_path, start_time="00:01:00", end_time="00:02:00"):
    """Trims an MKV file using output seeking."""
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        input_path,  # Input first
        "-ss",
        start_time,  # Seek after input
        "-to",
        end_time,
        "-c",
        "copy",
        output_path,
    ]
    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    return result.returncode == 0


def conjoin_videos(file_list, output_path):
    """Concatenates multiple MKV files into a single file using FFmpeg's concat demuxer."""
    concat_file = "concat_list.txt"

    # Create the temporary concat manifest
    with open(concat_file, "w", encoding="utf-8") as f:
        for file in file_list:
            # Escape single quotes for FFmpeg safety
            escaped_path = file.replace("'", "'\\''")
            f.write(f"file '{escaped_path}'\n")

    cmd = [
        "ffmpeg",
        "-y",
        "-f",
        "concat",
        "-safe",
        "0",
        "-i",
        concat_file,
        "-c",
        "copy",
        output_path,
    ]

    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    if os.path.exists(concat_file):
        os.remove(concat_file)

    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser(
        description="Trim filler intro/outro from MKV files in an input folder."
    )
    parser.add_argument(
        "-i",
        "--input-dir",
        default="input",
        help="Directory containing source MKV files (default: input)",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default="output",
        help="Directory where trimmed/conjoined files will be saved (default: output)",
    )
    parser.add_argument(
        "-s",
        "--start",
        default="00:01:50",
        help="Start timestamp to keep (default: 00:01:50)",
    )
    parser.add_argument(
        "-e",
        "--end",
        default="00:22:35",
        help="End timestamp to keep (default: 00:22:35)",
    )
    parser.add_argument(
        "--conjoin",
        action="store_true",
        help="Merge trimmed files into a single output file",
    )
    parser.add_argument(
        "--joined-filename",
        default="conjoined_output.mkv",
        help="Filename for the conjoined output inside output dir (default: conjoined_output.mkv)",
    )

    args = parser.parse_args()

    # Verify input directory exists
    if not os.path.isdir(args.input_dir):
        print(f"❌ Input directory '{args.input_dir}' does not exist.")
        sys.exit(1)

    # Find and sort files to keep episodic/chronological order
    pattern = os.path.join(args.input_dir, "*.mkv")
    mkv_files = sorted(glob.glob(pattern))

    if not mkv_files:
        print(f"No .mkv files found in directory: '{args.input_dir}'")
        sys.exit(1)

    # Ensure output directory exists
    os.makedirs(args.output_dir, exist_ok=True)

    trimmed_files = []

    print(f"Found {len(mkv_files)} .mkv file(s) in '{args.input_dir}'. Processing...\n")

    for idx, filepath in enumerate(mkv_files, 1):
        filename = os.path.basename(filepath)
        out_path = os.path.join(args.output_dir, f"trimmed_{filename}")

        print(f"[{idx}/{len(mkv_files)}] Trimming: {filename}...")

        success = trim_video(filepath, out_path, args.start, args.end)
        if success:
            trimmed_files.append(out_path)
        else:
            print(f"  ❌ Error processing {filename}")

    print(f"\nSuccessfully trimmed {len(trimmed_files)} file(s) -> '{args.output_dir}/'")

    if args.conjoin and trimmed_files:
        joined_output = os.path.join(args.output_dir, args.joined_filename)
        print(f"\nConjoining {len(trimmed_files)} files into '{joined_output}'...")

        if conjoin_videos(trimmed_files, joined_output):
            print(f"✅ Conjoined video saved to: {joined_output}")
        else:
            print("❌ Error occurred during conjoining.")


if __name__ == "__main__":
    main()
