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

apt_install() {
 if [ -x "/usr/bin/apt-get" ];
 then
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
  apt -y install apt-transport-https
  echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
  apt -y update
  apt -y install sublime-text
  apt -y install -f
 else
  echo "'apt-get' package manager not found"
 fi
}

yum_install() {
 if [ -x "/usr/bin/yum" ];
 then
  rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  yum -y install sublime-text
 else
  echo "'yum' package manager not found"
 fi
}

zypper_install() {
 if [ -x "/usr/bin/zypper" ];
 then
  rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  zypper addrepo -g -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  zypper install sublime-text
 else
  echo "'zypper' package manager not found"
 fi
}
pacman_install() {
 if [ -x "/usr/bin/pacman" ];
 then
  curl -O https://download.sublimetext.com/sublimehq-pub.gpg && pacman-key --add sublimehq-pub.gpg && pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
  if grep -q 'Server = https://download.sublimetext.com/arch/stable/x86_64' "/etc/pacman.conf";
  then
	echo "source already added"
  else
	echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | tee -a /etc/pacman.conf
  fi
  echo "update"
  yes | pacman -Syu sublime-text
 else
  echo "'pacman' package manager not found"
 fi
}
do_install
