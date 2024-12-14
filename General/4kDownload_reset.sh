pkill -f 4kvideodownloaderplus
cp "/home/USER/Videos/4K Video Downloader+"/* /home/standard/Videos/backup/
sudo apt -y remove 4kvideodownloaderplus
find / \( -path '/home/USER/Downloads' -o -path '/mnt' \) -prune -o -iname '4k*video*' -print0 2>/dev/null | while IFS= read -r -d '' i; do rm -rf "$i"; done
sudo dpkg -i /home/USER/Downloads/4kdl.deb
