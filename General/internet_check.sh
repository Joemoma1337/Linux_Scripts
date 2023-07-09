#!/bin/bash
# Check internet connection
ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Internet available."
else
    echo "Internet connection is not available. Rebooting services..."
    systemctl restart service1
    systemctl restart service2
fi
