#!/bin/bash
#check for package manager
var=$(ls /usr/bin | grep -E "^pacman|^apt|^zypper|^yum|^eopkg" | head -n 1)
echo "found $var package manager"
apt_update() {
	echo "===== Signing Key ====="
	apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7
	echo "===== Repository ====="
	echo 'deb https://repo.windscribe.com/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/windscribe-repo.list
	echo "===== update ====="
	apt -y update
	echo "===== Install ====="
	apt-get -y install windscribe-cli
	echo "===== Fix ====="
	apt -y install -f
}
yum_update() {
	echo "===== Wget ====="
	wget https://repo.windscribe.com/fedora/windscribe.repo -O /etc/yum.repos.d/windscribe.repo
	echo "===== Update ====="
	yum -y update
	echo "===== Install ====="
	yum -y install windscribe-cli
}
zypper_update() {
	echo "Zypper detected, unable to install"
	echo "check Windscribe support"
}
pacman_update() {
	echo "Zypper detected, unable to install"
	echo "check Windscribe support"
}
if [ $var == 'apt' 2>/dev/null ]; then
	apt_update
elif [ $var == 'yum' 2>/dev/null ]; then
	yum_update
elif [ $var == 'zypper' 2>/dev/null ]; then
	zypper_update
elif [ $var == 'pacman' 2>/dev/null ]; then
	pacman_update
elif [ -z $var ]; then
	echo 'error, check package manager'
fi
