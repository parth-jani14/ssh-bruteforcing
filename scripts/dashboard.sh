#!/bin/bash

# Live monitoring dashboard
watch -n 5 -t -c '
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        SSH SECURITY SYSTEM - LIVE DASHBOARD               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "┌─ SERVICES STATUS ──────────────────────────────────────────┐"
systemctl is-active cowrie >/dev/null 2>&1 && echo "│ Cowrie:    ✓ Running" || echo "│ Cowrie:    ✗ Stopped"
systemctl is-active fail2ban >/dev/null 2>&1 && echo "│ Fail2ban:  ✓ Running" || echo "│ Fail2ban:  ✗ Stopped"
systemctl is-active sshd >/dev/null 2>&1 && echo "│ SSH:       ✓ Running" || echo "│ SSH:       ✗ Stopped"
sudo /opt/splunkforwarder/bin/splunk status 2>/dev/null | grep -q "running" && echo "│ Splunk:    ✓ Running" || echo "│ Splunk:    ✗ Stopped"
echo "└────────────────────────────────────────────────────────────┘"
echo ""
echo "┌─ ATTACK STATISTICS ────────────────────────────────────────┐"
TOTAL_ATTACKS=$(grep -c "login attempt" ~/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log 2>/dev/null || echo 0)
UNIQUE_IPS=$(grep -oP "(?<=from )[0-9.]+(?=:)" ~/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log 2>/dev/null | sort -u | wc -l || echo 0)
BLOCKED_IPS=$(grep -c "^ALL:" /etc/hosts.deny 2>/dev/null || echo 0)
echo "│ Total Login Attempts:    $TOTAL_ATTACKS"
echo "│ Unique Attacker IPs:     $UNIQUE_IPS"
echo "│ Currently Blocked IPs:   $BLOCKED_IPS"
echo "└────────────────────────────────────────────────────────────┘"
echo ""
echo "┌─ FAIL2BAN STATUS ──────────────────────────────────────────┐"
sudo fail2ban-client status cowrie 2>/dev/null | grep "Currently banned" || echo "│ Cowrie jail: No data"
sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" || echo "│ SSHD jail: No data"
echo "└────────────────────────────────────────────────────────────┘"
echo ""
echo "┌─ RECENT ATTACKS (Last 5) ──────────────────────────────────┐"
grep "login attempt" ~/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log 2>/dev/null | tail -5 | while read line; do
    IP=$(echo "$line" | grep -oP "(?<=from )[0-9.]+(?=:)")
    USER=$(echo "$line" | grep -oP "login attempt \[\K[^/]+")
    echo "│ $IP -> $USER"
done
echo "└────────────────────────────────────────────────────────────┘"
echo ""
echo "Press Ctrl+C to exit | Updates every 5 seconds"
'
