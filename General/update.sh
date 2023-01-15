#!/bin/sh
package_managers=("apt-get" "dnf" "yum" "pacman" "zypper" "eopkg")
update_packages() {
    if command -v "$1" 2> /dev/null; then
        echo "Updating packages using $1..."
        case "$1" in
            "===== apt-get =====")
                apt-get -y update && apt-get -y dist-upgrade && apt-get -y upgrade && apt-get -y install -f && apt-get -y autoremove
                ;;
            "===== dnf =====")
                dnf -y makecache && dnf -y check-update && dnf -y upgrade
                ;;
            "===== yum =====")
                yum update -y && yum upgrade -y
                ;;
            "===== pacman =====")
                yes | pacman -Syu
                ;;
            "===== zypper =====")
                zypper --non-interactive update
                ;;
            "===== eopkg =====")
                eopkg upgrade -y
                ;;
            *)
                error "Error: Unsupported package manager $1"
                return 1
                ;;
        esac
    else
        error "Error: $1 is not installed."
        return 1
    fi
}
error() {
    >&2 echo "$1"
}
for package_manager in "${package_managers[@]}"; do
    update_packages "$package_manager" || break
done
