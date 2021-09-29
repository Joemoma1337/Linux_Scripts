#!/bin/bash
#The elif statement stands for else if and offers a convenient means for implementing chain logic. Find out how elif works by assessing the following example
echo -n "Enter a number: "
read num

if [[ $num -gt 10 ]]
then
echo "Number is greater than 10."
elif [[ $num -eq 10 ]]
then
echo "Number is equal to 10."
else
echo "Number is less than 10."
fi