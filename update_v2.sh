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
# check for apt-get package manager)
install_apt() {
    if check_cmd apt-get; then
        echo "" && echo "===== Update ======"
        #apt -y update
        echo "" && echo "===== Dist-Upgrade ====="
        #apt -y dist-upgrade
        echo "" && echo "===== Upgrade ======"
        #apt -y upgrade
        echo "" && echo "===== Fix Dependancies ======"
        #apt -y install -f
        echo "" && echo "===== Autoremove ======"
        #apt -y autoremove
        exit
    fi
}
# check for yum package manager)
install_yum() {
    if check_cmd yum && check_cmd yum-config-manager; then
        get_install_opts_for_yum
        echo "" && echo "===== Update ======"
        yum update -y
        echo "" && echo "===== upgrade ======"
        yum upgrade -y
        exit
    fi
}
# check for dnf package manager)
install_pacman() {
    if check_cmd pacman; then
        echo "" && echo "===== Starting update ====="
        yes | pacman -Syu
        exit
    fi
}
# check for zypper package manager)
install_zypper() {
    if check_cmd zypper; then
        echo "" && echo "===== Starting update ====="
        zypper --non-interactive update
        exit
    fi
}

install_apt
install_yum
install_dnf
install_zypper

# None of the known package managers (apt, yum, dnf, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1#!/bin/sh
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
# check for apt-get package manager)
install_apt() {
    if check_cmd apt-get; then
        echo "" && echo "===== Update ======"
        #apt -y update
        echo "" && echo "===== Dist-Upgrade ====="
        #apt -y dist-upgrade
        echo "" && echo "===== Upgrade ======"
        #apt -y upgrade
        echo "" && echo "===== Fix Dependancies ======"
        #apt -y install -f
        echo "" && echo "===== Autoremove ======"
        #apt -y autoremove
        exit
    fi
}
# check for yum package manager)
install_yum() {
    if check_cmd yum && check_cmd yum-config-manager; then
        get_install_opts_for_yum
        echo "" && echo "===== Update ======"
        yum update -y
        echo "" && echo "===== upgrade ======"
        yum upgrade -y
        exit
    fi
}
# check for dnf package manager)
install_pacman() {
    if check_cmd pacman; then
        echo "" && echo "===== Starting update ====="
        yes | pacman -Syu
        exit
    fi
}
# check for zypper package manager)
install_zypper() {
    if check_cmd zypper; then
        echo "" && echo "===== Starting update ====="
        zypper --non-interactive update
        exit
    fi
}

install_apt
install_yum
install_dnf
install_zypper

# None of the known package managers (apt, yum, dnf, zypper) are available
echo "Error: Couldn't identify the package manager"
exit 1
