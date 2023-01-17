#!/bin/bash
array=("Boltzmann" "Vltava" "Jardin" "Wurstchen" "Grafton" "Duomo" "Tulip" "Vistula" "Ikea" "Lindenhof" "Custard" "Ghost" "Phooey" "Drift" "Marina Bay" "Han River" "station")

size=${#array[@]}
index=$(( $RANDOM % $size ))
windscribe-cli connect "${array[$index]}"
