#!/bin/bash
directory="/home/user/Openvpn"
files=()
for file in "$directory"/*.ovpn; do
	if [ -f "$file" ]; then
		files+=("$file")
	fi
done

size=${#files[@]}

if [ "$size" -eq 0 ]; then
		echo "no .ovpn files found in directory"
		exit 1
fi
index=$(( RANDOM % size ))

sudo openvpn ${files[$index]}
