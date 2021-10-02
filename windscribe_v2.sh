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
#check for package mangers
check_cmd() {
    command -v "$1" 2> /dev/null
}
apt_install() {
    if check_cmd apt-get; then
        echo "===== Signing Key ====="
        apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7
        echo "===== Repository ====="
        echo 'deb https://repo.windscribe.com/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/windscribe-repo.list
        echo "===== update =====" && apt -y update
        echo "===== Install =====" && apt-get -y install windscribe-cli
        echo "===== Fix =====" && apt -y install -f
        exit
    fi
}
yum_install() {
    if check_cmd yum && check_cmd yum-config-manager; then
        echo "===== Wget =====" && wget https://repo.windscribe.com/fedora/windscribe.repo -O /etc/yum.repos.d/windscribe.repo
	echo "===== Add-epel =====" && yum -y install epel-release
        echo "===== Update =====" && yum -y update
        echo "===== Install =====" && yum -y install windscribe-cli
        exit
    fi
}
pacman_install() {
    if check_cmd pacman; then
        echo "Pacman detected, unable to install" && echo "check Windscribe support"
        exit
    fi
}
zypper_install() {
    if check_cmd zypper; then
        echo "Zypper detected, unable to install" && echo "check Windscribe support"
        exit
    fi
}
eopkg_install() {
    if check_cmd eopkg; then
        echo "" && echo "Eopkg detected, unable to install" && echo "" && echo "check Windscribe support"
        exit
    fi
}
apt_install
yum_install
pacman_install
zypper_install
eopkg_install
# None of the known package managers (apt, yum, pacman, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
