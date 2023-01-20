#!/bin/bash
lsblk | grep sd | awk '{print $1,$4,$7}'
echo ""&&echo -n "enter drive (example: /dev/sda1): "&& read drive
echo -n "what format (example: ext4, fat32, ntfs): "&& read format
echo -n "enter new drive name (uppercase): "&&read name
sub='/dev/'
if grep -q "$sub" <<< "$drive"; then
	drive2=$(echo $drive | cut -d '/' -f 3)
	mount=$(lsblk | grep $drive2 | awk '{print $7}')
	umount $mount
	sudo wipefs -a $drive'1'
	echo ';' | sudo sfdisk $drive
	if [[ "$format" == fat32 ]]; then
		echo y | sudo mkfs.fat $drive'1'
		sudo fatlabel $drive'1' $name
	elif [[ "$format" == ext4 ]]; then
		echo y | sudo mkfs.ext4 $drive'1'
		sudo e2label $drive'1' $name
	elif [[ "$format" == ntfs ]]; then
		echo y | sudo mkfs.ntfs -f $drive'1'
		sudo ntfslabel $drive'1' $name
	fi
	echo ""&&echo "===== Partitioning Complete! ====="
elif grep -vq "$sub" <<< "$var1"; then
	:
fi
# if creating Win10 bootable:
# mount Win10.iso and USB (after partition script)
# copy contents of Win10.iso to new partition (sda1, sda2, etc)
