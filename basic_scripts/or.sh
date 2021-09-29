#!/bin/bash
#The OR operator is another crucial construct that allows us to implement complex, robust programming logic in our scripts. Contrary to AND, a statement consisting of the OR operator returns true when either one of its operands is true. It returns false only when each operand separated by the OR is false
echo -n "Enter any number:"
read n

if [[ ( $n -eq 15 || $n -eq 45 ) ]]
then
echo "You won"
else
echo "You lost!"
fi