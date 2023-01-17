#!/bin/bash
echo -n "User (example: JohnSmith): "
read user
echo -n "Password for that user: "
read pass
echo -n "DC hostname/IP: "
read dc
#Hash password into ntlm
HASH=$(echo -n "$pass" | iconv -f ASCII -t UTF-16LE | openssl dgst -md4 | cut -d ' ' -f2)
#Enumerate accounts and passwords
echo "Exporting user+hashes, please wait..."
impacket-secretsdump -just-dc LAB/$user@$dc -hashes aad3b435b51404eeaad3b435b51404ee:$HASH > domain_dump.txt
#Cleanup only users and hashes
grep ':::' domain_dump.txt | egrep -v 'Guest|DefaultAccount' > domain_clean.txt
#Crack hashes
hashcat -m 1000 -a 0 domain_clean.txt /usr/share/wordlists/rockyou.txt -o hits.txt
echo "Cracking complete, please see Needs_Reset.txt"
#Enumerate users that need to reset their passwords
> Needs_Reset.txt
for i in $(cut -d ':' -f1 hits.txt); do grep $i domain_clean.txt | cut -d ':' -f1|cut -d '\' -f2 >> Needs_Reset.txt; done
#remove .potfile so that we cannot see the users and their passwords
> /home/standard/.local/share/hashcat/hashcat.potfile
