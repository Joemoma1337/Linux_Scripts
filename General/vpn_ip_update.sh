#!/bin/bash
#OpenVPN
oldIPvar=$(cat /etc/openvpn/easy-rsa/pki/Default.txt|grep 'remote '|cut -d ' ' -f2)
newIPvar=$(curl ifconfig.me/ip)
sed -i "s/$oldIPvar/$newIPvar/g" /etc/openvpn/easy-rsa/pki/Default.txt

#Wireguard
oldIPvar=$(cat /etc/pivpn/wireguard/setupVars.conf|grep pivpnHOST|cut -d '=' -f2)
newIPvar=$(curl ifconfig.me/ip)
sed -i "s/$oldIPvar/$newIPvar/g" /etc/pivpn/wireguard/setupVars.conf
