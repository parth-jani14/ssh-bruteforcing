#!/bin/bash

COWRIE_LOG="$HOME/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log"
FAIL2BAN_LOG="/var/log/fail2ban.log"
OUTPUT_DIR="$HOME/ssh-security-project/logs/analysis"

mkdir -p "$OUTPUT_DIR"

REPORT_FILE="$OUTPUT_DIR/report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== Splunk-Style Log Analysis ===" | tee "$REPORT_FILE"
echo "Generated: $(date)" | tee -a "$REPORT_FILE"

# Attack timeline
echo -e "\n--- Attack Timeline (Last 100 attempts) ---" | tee -a "$REPORT_FILE"
grep "login attempt" "$COWRIE_LOG" 2>/dev/null | tail -100 | awk '{print $1, $2}' | sort | uniq -c | tee -a "$REPORT_FILE"

# Top attack sources
echo -e "\n--- Top Attack Sources ---" | tee -a "$REPORT_FILE"
grep -oP '(?<=from )[0-9.]+(?=:)' "$COWRIE_LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -20 | tee -a "$REPORT_FILE"

# Most used usernames
echo -e "\n--- Most Used Usernames ---" | tee -a "$REPORT_FILE"
grep -oP 'login attempt \[\K[^/]+' "$COWRIE_LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -15 | tee -a "$REPORT_FILE"

# Most used passwords
echo -e "\n--- Most Used Passwords ---" | tee -a "$REPORT_FILE"
grep -oP 'login attempt \[[^]]+\] \(\K[^)]+' "$COWRIE_LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -15 | tee -a "$REPORT_FILE"

# Fail2ban statistics
echo -e "\n--- Fail2ban Ban Actions (Last 50) ---" | tee -a "$REPORT_FILE"
sudo grep "Ban" "$FAIL2BAN_LOG" 2>/dev/null | tail -50 | tee -a "$REPORT_FILE"

# Active bans
echo -e "\n--- Currently Banned IPs ---" | tee -a "$REPORT_FILE"
sudo fail2ban-client status cowrie 2>/dev/null | grep "Banned IP list" | tee -a "$REPORT_FILE"

# Attack intensity by hour
echo -e "\n--- Attack Intensity by Hour ---" | tee -a "$REPORT_FILE"
grep "login attempt" "$COWRIE_LOG" 2>/dev/null | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | tee -a "$REPORT_FILE"

echo -e "\nReport saved to: $REPORT_FILE"
