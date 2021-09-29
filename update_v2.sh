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
update_apt() {
    if check_cmd apt-get; then
        echo "" && echo "===== Update ======"
        apt -y update
        echo "" && echo "===== Dist-Upgrade ====="
        apt -y dist-upgrade
        echo "" && echo "===== Upgrade ======"
        apt -y upgrade
        echo "" && echo "===== Fix Dependancies ======"
        apt -y install -f
        echo "" && echo "===== Autoremove ======"
        apt -y autoremove
        exit
    fi
}
update_yum() {
    if check_cmd yum && check_cmd yum-config-manager; then
        get_update_opts_for_yum
        echo "" && echo "===== Update ======"
        yum update -y
        echo "" && echo "===== upgrade ======"
        yum upgrade -y
        exit
    fi
}
update_pacman() {
    if check_cmd pacman; then
        echo "" && echo "===== Starting update ====="
        yes | pacman -Syu
        exit
    fi
}
update_zypper() {
    if check_cmd zypper; then
        echo "" && echo "===== Starting update ====="
        zypper --non-interactive update
        exit
    fi
}
update_eopkg() {
    if check_cmd eopkg; then
        echo "" && echo "===== Starting update ====="
        eopkg upgrade -y
        exit
    fi
}
update_apt
update_yum
update_pacman
update_zypper
update_eopkg
# None of the known package managers (apt, yum, pacman, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
