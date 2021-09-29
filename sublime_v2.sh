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
install_apt() {
    if check_cmd apt-get; then
      wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
      apt -y install apt-transport-https
      echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
      apt -y update
      apt -y install sublime-text
      apt -y install -f
      exit
    fi
}
install_yum() {
    if check_cmd yum && check_cmd yum-config-manager; then
        rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        yum -y install sublime-text
        exit
    fi
}
install_pacman() {
    if check_cmd pacman; then
        curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
        if grep -q 'Server = https://download.sublimetext.com/arch/stable/x86_64' "/etc/pacman.conf";
            then
            echo "source already added"
            else
            echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
        fi
        echo "===== update ====="
        yes | pacman -Syu sublime-text
        exit
    fi
}
install_zypper() {
    if check_cmd zypper; then
        rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        zypper install sublime-text
        exit
    fi
}
install_apt
install_yum
install_pacman
install_zypper
# None of the known package managers (apt, yum, pacman, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
