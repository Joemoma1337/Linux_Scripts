#!/bin/sh
# check for root access
SUDO=
if [ "$(id -u)" -ne 0 ]; then
    SUDO=$(command -v sudo 2> /dev/null)
    if [ ! -x "$SUDO" ]; then
        echo "Error: Run this script as root"
        exit 1
    fi
fi
check_cmd() {
    command -v "$1" 2> /dev/null
}
 apt_install() {
    if check_cmd apt-get; then
      wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
      apt -y install apt-transport-https
      echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
      echo "===== update =====" && apt -y update
      echo "===== Install =====" && apt -y install sublime-text
      echo "===== Fix-Broken =====" && apt -y install -f
      exit
    fi
}
dnf_install() {
    if check_cmd dnf; then
        echo "===== Import =====" && rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        echo "===== Add-Repo =====" && dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        echo "===== Install =====" && dnf -y install sublime-text
        exit
    fi
}
yum_install() {
    if check_cmd yum && check_cmd yum-config-manager; then
        echo "===== Import =====" && rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        echo "===== Add-Repo =====" && yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        echo "===== Install =====" && yum -y install sublime-text
        exit
    fi
}
pacman_install() {
    if check_cmd pacman; then
        echo "===== Curl ====="
        curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
        if grep -q 'Server = https://download.sublimetext.com/arch/stable/x86_64' "/etc/pacman.conf";
            then
            echo "source already added"
            else
            echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
        fi
        echo "===== Install =====" && yes | pacman -Syu sublime-text
        exit
    fi
}
zypper_install() {
    if check_cmd zypper; then
        echo "===== Import =====" && rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        echo "===== Add-Repo =====" && zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        echo "===== Install =====" && zypper --non-interactive install sublime-text
        exit
    fi
}
apt_install
dnf_install
yum_install
pacman_install
zypper_install
# None of the known package managers (apt, yum, pacman, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
