detect_pkgmgr() {
  ls /usr/bin | grep -E "^$*"
}

do_update() {
  echo "Detecting Package Manger ... "

  detect_pkgmgr "apt-get" && echo "Found Apt" && apt_update && return
  detect_pkgmgr "yum" && echo "Found Yum" && yum_update && return
  detect_pkgmgr "pacman" && echo "Found Pacman" && pacman_update && return
  detect_pkgmgr "zypper" && echo "Found Zypper" && zypper_update && return
}

apt_update() {
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

yum_update() {
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

zypper_update() {
#check for zypper packager manager
 if [ -x "/usr/bin/zypper" ];
 then
   echo "Starting update ..."
   zypper --non-interactive update
 else
   echo "'zypper' package manager not found"
 fi
}

eopkg_update() {
#check for eopkg packager manager
 if [ -x "/usr/bin/eopkg" ];
 then
   echo "Starting update ..."
   eopkg upgrade -y
 else
   echo "'eopkg' package manager not found"
 fi
}

pacman_update() {
#check for pacman packager manager
 if [ -x "/usr/bin/pacman" ];
 then
   echo "Starting update ..."
   yes | pacman -Syu
 else
   echo "'eopkg' package manager not found"
 fi
}
do_update
