#!/bin/bash

# Paths
COWRIE_LOG="$HOME/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log"
BLOCK_LOG="$HOME/ssh-security-project/logs/blocked_ips.log"
HOSTS_DENY="/etc/hosts.deny"
ATTACK_LOG="$HOME/ssh-security-project/logs/attack_summary.log"

# Create logs directory
mkdir -p ~/ssh-security-project/logs

# Extract IPs from cowrie log
extract_ips() {
    grep -oP '(?<=from )[0-9.]+(?=:)' "$COWRIE_LOG" 2>/dev/null | sort -u
}

# Block IP function
block_ip() {
    local IP=$1
    
    # IMPORTANT: Don't block your own network!
    if [[ "$IP" =~ ^192\.168\.1\. ]]; then
        echo "[$(date)] SKIPPED (local network): $IP" >> "$ATTACK_LOG"
        return 1
    fi
    
    # Check if already blocked
    if ! grep -q "$IP" "$HOSTS_DENY" 2>/dev/null; then
        echo "ALL: $IP # Blocked by monitor script $(date)" | sudo tee -a "$HOSTS_DENY" > /dev/null
        echo "[$(date)] BLOCKED: $IP" >> "$BLOCK_LOG"
        
        # Add to iptables
        sudo iptables -I BLOCKED_IPS -s "$IP" -j DROP
        
        return 0
    fi
    return 1
}

# Main execution
echo "=== Attack Monitor Started: $(date) ===" >> "$ATTACK_LOG"

BLOCKED_COUNT=0
for IP in $(extract_ips); do
    if block_ip "$IP"; then
        ((BLOCKED_COUNT++))
        echo "[$(date)] New attacker blocked: $IP" >> "$ATTACK_LOG"
    fi
done

echo "[$(date)] Scan complete. Newly blocked: $BLOCKED_COUNT IPs" >> "$ATTACK_LOG"

# Save iptables rules
if [ $BLOCKED_COUNT -gt 0 ]; then
    if command -v netfilter-persistent &> /dev/null; then
        sudo netfilter-persistent save
    elif command -v service &> /dev/null; then
        sudo service iptables save
    fi
fi
