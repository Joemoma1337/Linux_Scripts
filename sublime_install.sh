#!/bin/bash
var=$(ls /usr/bin | grep -E "^pacman|^apt|^zypper|^yum|^eopkg" | head -n 1)
echo "found $var package manager"
apt_install() {
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
apt -y install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt -y update
apt -y install sublime-text
apt -y install -f
}

yum_install() {
rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
yum -y install sublime-text
}

zypper_install() {
rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
zypper install sublime-text
}
pacman_install() {
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
if grep -q 'Server = https://download.sublimetext.com/arch/stable/x86_64' "/etc/pacman.conf";
then
	echo "===== source already added ====="
else
	echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
fi
echo "update"
yes | pacman -Syu sublime-text
}
if [ $var == 'apt' 2>/dev/null ]; then
	apt_install
elif [ $var == 'yum' 2>/dev/null ]; then
	yum_install
elif [ $var == 'zypper' 2>/dev/null ]; then
	zypper_install
elif [ $var == 'pacman' 2>/dev/null ]; then
	pacman_install
elif [ -z $var ]; then
	echo 'error, check package manager'
fi
