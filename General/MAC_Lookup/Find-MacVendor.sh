#!/bin/bash
# ==============================================================================
# MAC Address Vendor Lookup Script
# ==============================================================================
# This script reads a MAC address vendor database from a CSV file, then
# processes a list of lines from an input file to find and identify MAC
# addresses. It outputs the original line and the corresponding vendor name
# to a new CSV file.
#
# Vendor database can be downloaded from here: https://maclookup.app/downloads/csv-database
#
# The script can handle various MAC address formats, including:
# - aa:bb:cc:dd:ee:ff
# - aa-bb-cc-dd-ee-ff
# - aa.bb.cc.dd.ee.ff
# - aabb.ccdd.eeff (Cisco style)
#
# Prerequisites:
# - Bash version 4.0 or higher for associative arrays.
# ==============================================================================
# --- Define file paths ---
# The input file containing lines to search for MAC addresses.
inputFile="MAC_Input.txt"
# The CSV file containing the MAC prefix to vendor name database.
dbFile="MAC_VendorDB.csv"
# The output CSV file where results will be written.
outputFile="MAC_Output.csv"

# Check if the required files exist
if [ ! -f "$inputFile" ]; then
    echo "Error: Input file '$inputFile' not found!"
    exit 1
fi
if [ ! -f "$dbFile" ]; then
    echo "Error: Database file '$dbFile' not found!"
    exit 1
fi

# --- Load the vendor database into an associative array ---
# This is the Bash equivalent of a PowerShell hash table.
# 'declare -A' creates an associative array.
declare -A vendorDB

echo "Loading vendor database..."
# Use IFS=, to set the field separator to a comma for reading the CSV.
# The 'head -n 1' and 'tail -n +2' pipe is to skip the header line.
# This loop reads each line of the CSV and populates the array.
tail -n +2 "$dbFile" | while IFS=',' read -r macPrefix vendorName _; do
    # Remove colons from the MAC prefix to match the input format.
    cleanPrefix=$(echo "$macPrefix" | tr -d ':')
    vendorDB["$cleanPrefix"]="$vendorName"
done

# --- Process the input file and generate output ---
echo "Processing input file..."

# Redirect all the output to the output file
{
    # Print the CSV header
    echo "\"Original Line\",\"Vendor\""

    # Define a more flexible regular expression for MAC addresses.
    # It handles various separators (:, -, .) and formats.
    macRegex='([0-9a-fA-F]{2}[:-]?){5}[0-9a-fA-F]{2}|([0-9a-fA-F]{4}[.-]?){2}[0-9a-fA-F]{4}'

    # Read the input file line by line
    while IFS= read -r line; do
        # Check if the line contains a MAC address using the regex
        if [[ "$line" =~ $macRegex ]]; then
            # The matched part is stored in BASH_REMATCH[0]
            macAddress="${BASH_REMATCH[0]}"

            # Remove all separators (:, -, .) to get a clean MAC address string
            cleanMac=$(echo "$macAddress" | tr -d ':-.')

            # Get the first 6 characters (the OUI) for the lookup
            macPrefix=${cleanMac:0:6}

            # Look up the vendor in the associative array
            vendorName="${vendorDB[${macPrefix^^}]}" # Use ^^ for case-insensitivity

            # If a vendor is found, use its name; otherwise, use "Unknown"
            if [[ -n "$vendorName" ]]; then
                # Use printf for consistent CSV output
                printf "\"%s\",\"%s\"\n" "$line" "$vendorName"
            else
                printf "\"%s\",\"%s\"\n" "$line" "Unknown"
            fi
        else
            # If no MAC address is found, output "N/A" for the vendor
            printf "\"%s\",\"%s\"\n" "$line" "N/A"
        fi
    done < "$inputFile"
} > "$outputFile"

# --- Confirmation message ---
echo "Processing complete. Results saved to $outputFile"
