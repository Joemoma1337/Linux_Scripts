#!/bin/bash
#enumerate accounts and passwords
impacket-secretsdump -just-dc LAB/root:"P@ssw0rd!"@10.0.4.18 > domain_dump.txt
#cleanup only users and hashes
cat domain_dump.txt | grep ':::' > domain_clean.txt
rm domain_dump.txt
#crack hashes
hashcat -m 1000 -a 0 /home/standard/Documents/Domain_Dump/domain_clean.txt /usr/share/wordlists/rockyou.txt -o hits.txt
#enumerate users that need to reset their passwords
echo -n "" > Needs_Reset.txt
for i in $(cat hits.txt|cut -d ':' -f1); do grep $i domain_clean.txt | cut -d ':' -f1|cut -d '\' -f2 >> Needs_Reset.txt; done
#remove .potfile so that we cannot see the users and their passwords
rm hits.txt
echo "" > /home/standard/.local/share/hashcat/hashcat.potfile
