detect_pkgmgr() {
  ls /usr/bin | grep -E "^$*"
}

do_install() {
  echo "Detecting Package Manger ... "

  detect_pkgmgr "apt" && echo "Found Apt" && apt_install && return
  detect_pkgmgr "yum" && echo "Found Yum" && yum_install && return
  detect_pkgmgr "pacman" && echo "Found Pacman" && pacman_install && return
  detect_pkgmgr "zypper" && echo "Found Zypper" && zypper_install && return
}

dpkg_install() {
#check for apt-get package manager
 if [ -x "/usr/bin/apt-get" ];
 then
   echo "" && echo "===== Update ======"
   apt -y update
   echo "" && echo "===== Dist-Upgrade ====="
   apt -y dist-upgrade
   echo "" && echo "===== Upgrade ======"
   apt -y upgrade
   echo "" && echo "===== Autoremove ======"
   apt -y autoremove
   echo "" && echo "===== Fix Dependancies ======"
   apt -y install -f
 else
   echo "'apt-get' package manager not found"
 fi
}

yum_install() {
#check for yum packager manager
 if [ -x "/usr/bin/yum" ];
 then
   echo "" && echo "===== Update ======"
   yum update -y 
   echo "" && echo "===== upgrade ======"
   yum upgrade -y
 else
   echo "'yum' package manager not found"
 fi
}

zypper_install() {
#check for zypper packager manager
 if [ -x "/usr/bin/zypper" ];
 then
   echo "Starting update ..."
   zypper --non-interactive update
 else
   echo "'zypper' package manager not found"
 fi
}

eopkg_install() {
#check for eopkg packager manager
 if [ -x "/usr/bin/eopkg" ];
 then
   echo "Starting update ..."
   eopkg upgrade -y
 else
   echo "'eopkg' package manager not found"
 fi
}

pacman_install() {
#check for pacman packager manager
 if [ -x "/usr/bin/pacman" ];
 then
   echo "Starting update ..."
   yes | pacman -Syu
 else
   echo "'eopkg' package manager not found"
 fi
}
do_install
