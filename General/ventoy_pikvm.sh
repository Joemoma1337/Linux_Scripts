#!/bin/bash
echo "===== Working Directoy ====="
#create working directory
mkdir ~/Ventoy
cd Ventoy
echo "===== DD ====="
#create ventoy.img
echo 'What size do you want your ventoy.img to be? (numbers will be interpreted to GB, Ex: "10" would be 10GB)'
read count
dd if=/dev/zero of=ventoy.img bs=1024M count=$count status=progress
echo "===== Wget ====="
#download ventoy software
wget https://github.com/ventoy/Ventoy/releases/download/v1.0.51/ventoy-1.0.51-linux.tar.gz
tar zxvf ventoy-1.0.51-linux.tar.gz
echo "===== losetup ====="
#mount venoty.img to loop device
sudo losetup -f ventoy.img
#losetup -l | grep ventoy
ventoy_loop=$(losetup -l | grep ventoy | awk -F "/" '{print $3}' | awk -F " " '{print $1}')
#echo $ventoy_loop #ex: loop6
echo "===== sh ventoy ====="
#install ventoy to ventoy.img
sudo sh ventoy-1.0.51/Ventoy2Disk.sh -i /dev/$ventoy_loop
echo "===== mount ====="
#mount ventoy.img to directory
sudo mkdir /media/ventoy
sudo mount "/dev/$ventoy_loop"p1 /media/ventoy
echo "===== copy ====="
#copy images
echo "Full path to directory you wish to transfer ALL files from (ex: /home/ubuntu/Downloads)"
read iso_dir
sudo cp -v $iso_dir/* /media/ventoy

#Transferring to PiKVM
echo "===== Transfer ventoy.img to PiKVM ====="
echo "what is the IP of your PiKVM?"
read PiKVMIP
echo $PiKVMIP
echo "===== changing dir to rw ====="
ssh root@$PiKVMIP "mount -o remount,rw /var/lib/kvmd/msd"
echo "===== transferring ventoy.img ====="
scp ventoy.img root@$PiKVMIP:/var/lib/kvmd/msd
echo "===== create complete file ====="
ssh root@$PiKVMIP "touch /var/lib/kvmd/msd/.__ventoy.img.complete"
echo "===== changing dir to ro ====="
ssh root@$PiKVMIP "mount -o remount,ro /var/lib/kvmd/msd"

echo "===== cleanup ====="
sudo umount /media/ventoy
sudo losetup -d /dev/$ventoy_loop
sudo rm -rf /media/ventoy
