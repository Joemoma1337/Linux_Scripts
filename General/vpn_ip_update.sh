#!/bin/bash

# Get the current public IP address
readonly NEW_IP=$(curl -4 -s https://ifconfig.me/ip)

# OpenVPN
readonly OPENVPN_FILE="/etc/openvpn/easy-rsa/pki/Default.txt"
if [[ -f $OPENVPN_FILE ]]; then
    OLD_IP=$(awk '/remote / {print $2}' $OPENVPN_FILE)
    sed -i "s/$OLD_IP/$NEW_IP/g" $OPENVPN_FILE
fi

# Wireguard
readonly WIREGUARD_FILE="/etc/pivpn/wireguard/setupVars.conf"
if [[ -f $WIREGUARD_FILE ]]; then
    OLD_IP=$(awk -F '=' '/pivpnHOST/ {print $2}' $WIREGUARD_FILE)
    sed -i "s/$OLD_IP/$NEW_IP/g" $WIREGUARD_FILE
fi
