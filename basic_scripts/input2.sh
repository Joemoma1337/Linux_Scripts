#!/bin/bash
#The statements are only executed given the CONDITION is true. The fi keyword is used for marking the end of the if statement. A quick example is shown below
echo -n "Enter a number: "
read num

if [[ $num -gt 10 ]]
then
echo "Number is greater than 10."
fi