#!/bin/bash

COWRIE_LOG="$HOME/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log"
BLOCK_LOG="$HOME/ssh-security-project/logs/blocked_ips.log"

echo "=== SSH Attack Statistics ==="
echo "Report generated: $(date)"
echo ""

# Total unique attackers
echo "Total Unique Attacker IPs:"
grep -oP '(?<=from )[0-9.]+(?=:)' "$COWRIE_LOG" 2>/dev/null | sort -u | wc -l

# Total login attempts
echo ""
echo "Total Login Attempts:"
grep -c "login attempt" "$COWRIE_LOG" 2>/dev/null || echo "0"

# Top 10 attacking IPs
echo ""
echo "Top 10 Attacking IPs:"
grep -oP '(?<=from )[0-9.]+(?=:)' "$COWRIE_LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -10

# Currently blocked IPs
echo ""
echo "Currently Blocked IPs:"
grep -c "^ALL:" /etc/hosts.deny 2>/dev/null || echo "0"

# Recent attacks (last 24 hours)
echo ""
echo "Attacks in Last 24 Hours:"
if [ -f "$COWRIE_LOG" ]; then
    find "$COWRIE_LOG" -mtime -1 -exec grep -c "login attempt" {} \; 2>/dev/null || echo "0"
else
    echo "0"
fi
