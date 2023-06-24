#!/bin/bash
echo "===== ventoy.img ====="
echo "Specify path to ventoy.img (ex: /home/ubuntu/Ventoy/ventoy.img"
echo -n "/path/to/ventoy.img: "
read ventoy_dir

echo "===== losetup ====="
sudo losetup -f $ventoy_dir

ventoy_loop=$(losetup -l | grep ventoy | awk -F "/" '{print $3}' | awk -F " " '{print $1}')

echo "===== mount ====="
#mount ventoy.img to directory
if [ -d "/media/ventoy" ]; then
	continue 
else
	sudo mkdir /media/ventoy
fi
sudo mount "/dev/$ventoy_loop"p1 /media/ventoy

echo "===== copy ====="
echo "Full path to directory you wish to trasnsfer ALL files from (ex: /home/ubuntu/Downloads)"
echo -n "/path/to/dir: " && read iso_dir
sudo cp -v $iso_dir/* /media/ventoy

echo "===== cleanup ====="
sudo umount /media/ventoy
sudo losetup -d /dev/$ventoy_loop
