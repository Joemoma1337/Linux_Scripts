#!/bin/bash
#The above program will not work if your current working directory already contains a folder with the same name. For example, the below program will check for the existence of any folder named $dir and only create one if it finds none
echo -n "Enter directory name ->"
read dir
if [ -d "$dir" ]
then
echo "Directory exists"
else
`mkdir $dir`
echo "Directory created"
fi