#!/bin/bash

# --- Configuration ---
# Use multiple targets to avoid false positives
TARGETS=("8.8.8.8" "1.1.1.1" "google.com")
SERVICES=("service1" "service2")

# --- Logic ---
is_online() {
    for target in "${TARGETS[@]}"; do
        # -t 2: Wait 2 seconds for a response
        # -c 1: Send only 1 packet
        if ping -q -c 1 -W 2 "$target" > /dev/null 2>&1; then
            return 0 # Success
        fi
    done
    return 1 # All targets failed
}

if is_online; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Internet available."
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Connection lost. Restarting: ${SERVICES[*]}" >&2
    
    for service in "${SERVICES[@]}"; do
        systemctl restart "$service"
    done
fi
