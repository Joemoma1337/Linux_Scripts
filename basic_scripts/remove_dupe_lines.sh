#! /bin/sh
#File processing takes considerable time and hampers the productivity of admins in many ways. For example, searching for duplicates in your files can become a daunting task. Luckily, you can do this with a short shell script.
echo -n "Enter Filename-> "
read filename
if [ -f "$filename" ]; then
sort $filename | uniq | tee sorted.txt
else
echo "No $filename in $pwd...try again"
fi
exit 0