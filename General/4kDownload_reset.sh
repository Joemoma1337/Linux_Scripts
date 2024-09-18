pkill -f 4kvideodownloaderplus
sudo apt -y remove 4kvideodownloaderplus
find ./ -path './Downloads' -prune -o -iname '4k*video*' -print0 | while IFS= read -r -d '' i; do rm -rf "$i"; done
sudo dpkg -i ./Downloads/4kvideodownloaderplus_1.9.0-1_amd64.deb
