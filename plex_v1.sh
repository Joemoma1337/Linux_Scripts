curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
apt -y update
apt -y install plexmediaserver
sudo systemctl status plexmediaserver
#wget https://downloads.plex.tv/plex-media-server-new/1.24.5.5173-8dcc73a59/debian/plexmediaserver_1.24.5.5173-8dcc73a59_amd64.deb
#dpkg -i plexmediaserver_1.24.5.5173-8dcc73a59_amd64.deb
