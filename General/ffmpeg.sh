#CPU
for i in $(ls *.mkv); do ffmpeg -i "$i" -map 0 ../Backup/"2-${i}"; done ; cd ../S01
#GPU
for a in *.{mkv,mp4,m4v,avi}; do ffmpeg -hwaccel_output_format cuda -c:v h264_cuvid -i "$a" -c:a copy -c:v h264_nvenc -map 0 ../Backup/"${a}"; done
#GPU encode entire directory
for i in $(ls /Path/To/Source/|grep -Ev 'exclude1|exclude2');do cd /Path/To/Source/$i && for a in *.{mkv,mp4,m4v,avi}; do ffmpeg -hwaccel_output_format cuda -c:v h264_cuvid -i "$a" -c:a copy -c:v h264_nvenc -map 0 ../Backup/"${a}"; done; done
