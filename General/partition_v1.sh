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
	wipefs -a $drive'1'
	echo ';' | sfdisk $drive
	if [[ "$format" == fat32 ]]; then
		echo y | mkfs.fat $drive'1'
		fatlabel $drive'1' $name
	elif [[ "$format" == ext4 ]]; then
		echo y | mkfs.ext4 $drive'1'
		e2label $drive'1' $name
	elif [[ "$format" == ntfs ]]; then
		echo y | mkfs.ntfs -f $drive'1'
		ntfslabel $drive'1' $name
	fi
	echo ""&&echo "===== Partitioning Complete! ====="
elif grep -vq "$sub" <<< "$var1"; then
	:
fi
# if creating Win10 bootable:
# mount Win10.iso and USB (after partition script)
# copy contents of Win10.iso to new partition (sda1, sda2, etc)
