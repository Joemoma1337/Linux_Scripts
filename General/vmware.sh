#git clone https://github.com/mkubecek/vmware-host-modules
rm -rf vmware-host-modules
cp -r VMWare_host_modules_original/ vmware-host-modules
cd vmware-host-modules
git checkout workstation-17.5.1
sudo make
sudo make install
sudo reboot
