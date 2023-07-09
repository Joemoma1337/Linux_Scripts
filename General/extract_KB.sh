#!/bin/bash
# File containing the list
#file="file1.txt"
file=$1
# Regular expression pattern to match KB numbers
pattern="KB[0-9]+"
# Read the file line by line and extract KB numbers
while IFS= read -r line; do
  if [[ $line =~ $pattern ]]; then
    echo "${BASH_REMATCH[0]}"
  fi
done < "$file"
