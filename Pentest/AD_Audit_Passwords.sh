#!/bin/bash
#echo "impacket-secretsdump -just-dc LAB/<user>@<dc> -hashes aad3b435b51404eeaad3b435b51404ee:<password(hashed)"
echo -n "User (example: JohnSmith): "&&read user
echo -n "Password for that user: "&&read pass
echo -n "DC hostname/IP: "&&read dc
#####hash password into ntlm:
HASH=$(iconv -f ASCII -t UTF-16LE <(printf "$pass") | openssl dgst -md4 | cut -d ' ' -f2)

#####enumerate accounts and passwords
echo ""
echo "==========================================="
echo "== exporting user+hashes, please wait... =="
echo "==========================================="
impacket-secretsdump -just-dc LAB/$user@$dc -hashes aad3b435b51404eeaad3b435b51404ee:$HASH > domain_dump.txt

#####cleanup only users and hashes
cat domain_dump.txt | grep ':::' > domain_clean.txt
#rm domain_dump.txt

#####crack hashes
hashcat -m 1000 -a 0 /home/standard/Documents/Domain_Dump/domain_clean.txt /usr/share/wordlists/rockyou.txt -o hits.txt
echo ""
echo "==================================================="
echo "== Cracking complete, please see Needs_Reset.txt =="
echo "==================================================="
#####enumerate users that need to reset their passwords
echo -n "" > Needs_Reset.txt
for i in $(cat hits.txt|cut -d ':' -f1); do grep $i domain_clean.txt | cut -d ':' -f1|cut -d '\' -f2 >> Needs_Reset.txt; done

#####remove .potfile so that we cannot see the users and their passwords
#rm hits.txt
echo "" > /home/standard/.local/share/hashcat/hashcat.potfile
