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
	echo -e "${g}===== Signing Key =====${re}"
	apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7
	echo -e "${g}===== Repository =====${re}"
	echo 'deb https://repo.windscribe.com/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/windscribe-repo.list
	echo -e "${g}===== update =====${re}"
	apt -y update
	echo -e "${g}===== Install =====${re}"
	apt-get -y install windscribe-cli
	echo -e "${g}===== Fix =====${re}"
	apt -y install -f
}
yum_update() {
	echo -e "${g}===== Wget =====${re}"
	wget https://repo.windscribe.com/fedora/windscribe.repo -O /etc/yum.repos.d/windscribe.repo
	echo -e "${g}===== Update =====${re}"
	yum -y update
	echo -e "${g}===== Install =====${re}"
	yum -y install windscribe-cli
}
zypper_update() {
	echo -e "${r}Zypper detected, unable to install${re}"
	echo -e "${r}check Windscribe support${re}"
}
pacman_update() {
	echo -e "${r}Zypper detected, unable to install${re}"
	echo -e "${r}check Windscribe support${re}"
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
