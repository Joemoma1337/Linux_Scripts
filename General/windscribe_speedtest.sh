#!/bin/bash
array[0]="Boltzmann"
array[1]="Vltava"
array[2]="Jardin"
array[3]="Wurstchen"
array[4]="Grafton"
array[5]="Duomo"
array[6]="Tulip"
array[7]="Vistula"
array[8]="Ikea"
array[9]="Lindenhof"
array[10]="Custard"
array[11]="Ghost"
array[12]="Phooey"
array[13]="Drift"
array[14]="Marina Bay"
array[15]="Han River"
array[16]="station"

size=${#array[@]}
index=$(($RANDOM % $size))
#echo ${array[$index]}
echo "=========="
windscribe-cli connect ${array[$index]}|grep "Connected to "
sleep 5
speedtest --no-upload --simple|grep -v Upload
