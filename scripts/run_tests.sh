#!/bin/bash

echo "==================================="
echo "SSH Security System - Test Suite"
echo "==================================="
echo ""

PASS=0
FAIL=0

# Test 1: Check if Cowrie is running
echo "[TEST 1] Cowrie Honeypot Status"
if systemctl is-active --quiet cowrie; then
    echo "✓ PASS: Cowrie is running"
    ((PASS++))
else
    echo "✗ FAIL: Cowrie is not running"
    ((FAIL++))
fi

# Test 2: Check if fail2ban is running
echo -e "\n[TEST 2] Fail2ban Status"
if systemctl is-active --quiet fail2ban; then
    echo "✓ PASS: Fail2ban is running"
    ((PASS++))
else
    echo "✗ FAIL: Fail2ban is not running"
    ((FAIL++))
fi

# Test 3: Check SSH on correct port
echo -e "\n[TEST 3] SSH Port Configuration"
if sudo ss -tlnp | grep -q ":2200.*sshd"; then
    echo "✓ PASS: SSH running on port 2200"
    ((PASS++))
else
    echo "✗ FAIL: SSH not on port 2200"
    ((FAIL++))
fi

# Test 4: Check honeypot on port 2222
echo -e "\n[TEST 4] Honeypot Port Configuration"
if sudo ss -tlnp | grep -q ":2222"; then
    echo "✓ PASS: Honeypot listening on port 2222"
    ((PASS++))
else
    echo "✗ FAIL: Honeypot not on port 2222"
    ((FAIL++))
fi

# Test 5: Check port forwarding (22 -> 2222)
echo -e "\n[TEST 5] Port Forwarding Rules"
if sudo iptables -t nat -L PREROUTING -n | grep -q "tcp dpt:22 redir ports 2222"; then
    echo "✓ PASS: Port 22 redirects to 2222"
    ((PASS++))
else
    echo "✗ FAIL: Port forwarding not configured"
    ((FAIL++))
fi

# Test 6: Check fail2ban jails
echo -e "\n[TEST 6] Fail2ban Jails Configuration"
JAILS=$(sudo fail2ban-client status 2>/dev/null | grep -c "Jail list")
if [ "$JAILS" -gt 0 ]; then
    echo "✓ PASS: Fail2ban jails are configured"
    ((PASS++))
else
    echo "✗ FAIL: No fail2ban jails found"
    ((FAIL++))
fi

# Test 7: Check if Cowrie logs exist
echo -e "\n[TEST 7] Cowrie Log Files"
if [ -f "$HOME/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log" ]; then
    echo "✓ PASS: Cowrie log file exists"
    ((PASS++))
else
    echo "✗ FAIL: Cowrie log file not found"
    ((FAIL++))
fi

# Test 8: Check monitoring scripts
echo -e "\n[TEST 8] Monitoring Scripts"
if [ -x "$HOME/ssh-security-project/scripts/monitor_attacks.sh" ]; then
    echo "✓ PASS: Monitoring scripts are executable"
    ((PASS++))
else
    echo "✗ FAIL: Monitoring scripts not found or not executable"
    ((FAIL++))
fi

# Test 9: Check cron jobs
echo -e "\n[TEST 9] Automated Tasks (Cron)"
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c "ssh-security-project")
if [ "$CRON_COUNT" -ge 2 ]; then
    echo "✓ PASS: Cron jobs configured ($CRON_COUNT found)"
    ((PASS++))
else
    echo "✗ FAIL: Cron jobs not properly configured"
    ((FAIL++))
fi

# Test 10: Check Splunk Forwarder
echo -e "\n[TEST 10] Splunk Universal Forwarder"
if sudo /opt/splunkforwarder/bin/splunk status 2>/dev/null | grep -q "running"; then
    echo "✓ PASS: Splunk Forwarder is running"
    ((PASS++))
else
    echo "✗ FAIL: Splunk Forwarder not running"
    ((FAIL++))
fi

echo -e "\n==================================="
echo "Test Results: $PASS passed, $FAIL failed"
echo "==================================="

# Exit with error code if any tests failed
if [ $FAIL -gt 0 ]; then
    exit 1
else
    exit 0
fi
