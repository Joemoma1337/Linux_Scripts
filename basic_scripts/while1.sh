#!/bin/bash
#The while loop construct is used for running some instruction multiple times. Check out the following script called while.sh for a better understanding of this concept
i=0

while [ $i -le 2 ]
do
echo Number: $i
((i++))
done