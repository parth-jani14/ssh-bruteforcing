#!/bin/bash

echo "=== SSH Security Status ==="
echo ""
echo "Services:"
systemctl is-active cowrie >/dev/null 2>&1 && echo "✓ Cowrie: Running" || echo "✗ Cowrie: Stopped"
systemctl is-active fail2ban >/dev/null 2>&1 && echo "✓ Fail2ban: Running" || echo "✗ Fail2ban: Stopped"
systemctl is-active sshd >/dev/null 2>&1 && echo "✓ SSH: Running" || echo "✗ SSH: Stopped"

echo ""
echo "Fail2ban Jails:"
sudo fail2ban-client status 2>/dev/null | grep "Jail list"

echo ""
echo "Cowrie Jail Status:"
sudo fail2ban-client status cowrie 2>/dev/null | grep "Currently banned" || echo "Cowrie jail not found"

echo ""
echo "SSHD Jail Status:"
sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" || echo "SSHD jail not found"

echo ""
echo "Total Blocked IPs in hosts.deny:"
grep -c "^ALL:" /etc/hosts.deny 2>/dev/null || echo "0"

echo ""
echo "Total Blocked IPs in iptables BLOCKED_IPS chain:"
sudo iptables -L BLOCKED_IPS -n 2>/dev/null | grep -c "DROP" || echo "0"
