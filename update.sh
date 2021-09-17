#!/bin/bash
#check for package manager
var=$(ls /usr/bin | grep -E "^pacman|^apt|^zypper|^yum|^eopkg" | head -n 1)
echo "found $var package manager"
apt_update() {
	echo "" && echo "===== Update ======"
	apt -y update
	echo "" && echo "===== Dist-Upgrade ====="
	apt -y dist-upgrade
	echo "" && echo "===== Upgrade ======"
	apt -y upgrade
	echo "" && echo "===== Autoremove ======"
	apt -y autoremove
	echo "" && echo "===== Fix Dependancies ======"
	apt -y install -f
}
yum_update() {
	echo "" && echo "===== Update ======"
	yum update -y
	echo "" && echo "===== upgrade ======"
	yum upgrade -y
}
zypper_update() {
	echo "" && echo "===== Starting update ====="
	zypper --non-interactive update
}
eopkg_update() {
	echo "" && echo "===== Starting update ====="
	eopkg upgrade -y
}
pacman_update() {
	echo "" && echo "===== Starting update ====="
	yes | pacman -Syu
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
