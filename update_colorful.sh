#!/bin/bash
# Ansi color code variables
r="\e[0;91m"
b="\e[0;94m"
b_bg="\e[0;104m${expand_bg}"
r_bg="\e[0;101m${expand_bg}"
g_bg="\e[0;102m${expand_bg}"
g="\e[0;92m"
white="\e[0;97m"
u="\e[4m"
re="\e[0m"
#check for package manager
var=$(ls /usr/bin | grep -E "^pacman|^apt|^zypper|^yum|^eopkg" | head -n 1)
echo "found $var package manager"
apt_update() {
	echo "" && echo -e "${g}===== Update =====${re}"
	apt -y update
	echo "" && echo -e "${g}===== Dist-Upgrade =====${re}"
	apt -y dist-upgrade
	echo "" && echo -e "${g}===== Upgrade =====${re}"
	apt -y upgrade
	echo "" && echo -e "${g}===== Fix Dependancies =====${re}"
	apt -y install -f
	echo "" && echo -e "${g}===== Autoremove =====${re}"
	apt -y autoremove
}
yum_update() {
	echo "" && echo -e "${g}===== Update =====${re}"
	yum update -y
	echo "" && echo -e "${g}===== upgrade =====${re}"
	yum upgrade -y
}
zypper_update() {
	echo "" && echo -e "${g}===== Starting update =====${re}"
	zypper --non-interactive update
}
eopkg_update() {
	echo "" && echo -e "${g}===== Starting update =====${re}"
	eopkg upgrade -y
}
pacman_update() {
	echo "" && echo -e "${g}===== Starting update =====${re}"
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
