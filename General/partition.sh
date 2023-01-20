#!/bin/bash
lsblk | grep sd | awk '{print $1,$4,$7}'
echo ""&&echo -n "enter drive (example: sdb): "&& read drive
echo -n "what format (example: ext4, fat32, ntfs): "&& read format
echo -n "enter new drive name (example: 16gb): "&&read name
sub=/dev/
if grep -q "$sub" <<< "/dev/$drive"; then
    mount=$(lsblk | grep $drive | awk '{print $7}')
    umount $mount
    wipefs -a /dev/$drive'1'
    echo ';' | sfdisk /dev/$drive
    if [[ "$format" == fat32 ]]; then
        echo y | mkfs.fat /dev/$drive'1'
        fatlabel /dev/$drive'1' $name
    elif [[ "$format" == ext4 ]]; then
        echo y | mkfs.ext4 /dev/$drive'1'
        e2label /dev/$drive'1' $name
    elif [[ "$format" == ntfs ]]; then
        echo y | mkfs.ntfs -f /dev/$drive'1'
        ntfslabel /dev/$drive'1' $name
    fi
    echo ""&&echo "===== Partitioning Complete! ====="
elif grep -vq "$sub" <<< "$var1"; then
    :
fi
# if creating Win10 bootable:
# mount Win10.iso and USB (after partition script)
# copy contents of Win10.iso to new partition (sda1, sda2, etc)
