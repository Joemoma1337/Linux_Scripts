#!/bin/bash
#The AND operator allows our program to check if multiple conditions are satisfied at once or not. All parts separated by an AND operator must be true. Otherwise, the statement containing the AND will return false. Check the following bash script example for a better understanding of how AND works
echo -n "Enter Number:"
read num

if [[ ( $num -lt 10 ) && ( $num%2 -eq 0 ) ]]; then
echo "Even Number"
else
echo "Odd Number"
fi