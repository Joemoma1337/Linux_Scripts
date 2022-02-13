#!/bin/sh
check_cmd() {
    command -v "$1" 2> /dev/null
}
 apt_install() {
    if check_cmd apt-get; then
		echo "===== Curl =====" && curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
		echo "===== Add-Repo =====" && echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
		echo "===== Update =====" && apt-get update
		echo "===== Install =====" && apt-get install syncthing
      exit
    fi
}
dnf_install() {
    if check_cmd dnf; then
		echo "===== Wget =====" && wget https://github.com/syncthing/syncthing/releases/download/v1.19.0/syncthing-linux-amd64-v1.19.0.tar.gz -O /home/standard/Downloads/syncthing.tar.gz
		echo "===== cd 1 =====" && cd /home/standard/Downloads/
		echo "===== tar =====" && tar -xvof syncthing.tar.gz
		echo "===== cd 2 =====" && cd syncthing-linux-*
		echo "===== run =====" && ./syncthing&
       exit
    fi
}
yum_install() {
    if check_cmd yum && check_cmd yum-config-manager; then
        echo "===== Wget =====" && wget https://github.com/syncthing/syncthing/releases/download/v1.19.0/syncthing-linux-amd64-v1.19.0.tar.gz -O /home/standard/Downloads/syncthing.tar.gz
		echo "===== cd 1 =====" && cd /home/standard/Downloads/
		echo "===== tar =====" && tar -xvof syncthing.tar.gz
		echo "===== cd 2 =====" && cd syncthing-linux-*
		echo "===== run =====" && ./syncthing&
    fi
}
pacman_install() {
    if check_cmd pacman; then
        echo "===== Wget =====" && wget https://github.com/syncthing/syncthing/releases/download/v1.19.0/syncthing-linux-amd64-v1.19.0.tar.gz -O /home/standard/Downloads/syncthing.tar.gz
		echo "===== cd 1 =====" && cd /home/standard/Downloads/
		echo "===== tar =====" && tar -xvof syncthing.tar.gz
		echo "===== cd 2 =====" && cd syncthing-linux-*
		echo "===== run =====" && ./syncthing&
    fi
}
zypper_install() {
    if check_cmd zypper; then
        echo "===== Wget =====" && wget https://github.com/syncthing/syncthing/releases/download/v1.19.0/syncthing-linux-amd64-v1.19.0.tar.gz -O /home/standard/Downloads/syncthing.tar.gz
		echo "===== cd 1 =====" && cd /home/standard/Downloads/
		echo "===== tar =====" && tar -xvof syncthing.tar.gz
		echo "===== cd 2 =====" && cd syncthing-linux-*
		echo "===== run =====" && ./syncthing&
    fi
}
apt_install; dnf_install; yum_install; pacman_install; zypper_install
# None of the known package managers (apt, yum, pacman, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
