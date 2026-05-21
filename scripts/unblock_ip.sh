#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    exit 1
fi

IP=$1
HOSTS_DENY="/etc/hosts.deny"

# Remove from hosts.deny
sudo sed -i "/$IP/d" "$HOSTS_DENY"

# Remove from iptables
sudo iptables -D BLOCKED_IPS -s "$IP" -j DROP 2>/dev/null

# Remove from fail2ban
sudo fail2ban-client unban "$IP" 2>/dev/null

echo "[$(date)] Unblocked IP: $IP"

# Save iptables
if command -v netfilter-persistent &> /dev/null; then
    sudo netfilter-persistent save
else
    sudo service iptables save 2>/dev/null
fi
