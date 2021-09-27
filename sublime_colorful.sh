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
	echo -e "${g}===== Wget =====${re}"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
	echo -e "${g}===== Install =====${re}"
	apt -y install apt-transport-https
	echo -e "${g}===== edit sources.list =====${re}"
	echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
	echo -e "${g}===== Update =====${re}"
	apt -y update
	echo -e "${g}===== Install =====${re}"
	apt -y install sublime-text
	echo -e "${g}===== Fix =====${re}"
	apt -y install -f
}
yum_update() {
	echo -e "${g}===== Import =====${re}"
	rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	echo -e "${g}===== Add-Repo =====${re}"
	yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	echo -e "${g}===== Install =====${re}"
	yum -y install sublime-text
}
zypper_update() {
	echo -e "${g}===== Import =====${re}"
	rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	echo -e "${g}===== Add-Repo =====${re}"
	zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	echo -e "${g}===== Install =====${re}"
	zypper install sublime-text
}
pacman_update() {
	echo -e "${g}===== Curl =====${re}"
	curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
	if grep -q 'Server = https://download.sublimetext.com/arch/stable/x86_64' "/etc/pacman.conf";
	then
		echo "source already added"
	else
		echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
	fi
	echo -e "${g}===== Install =====${re}"
	yes | pacman -Syu sublime-text
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
