#!/bin/bash

COWRIE_LOG="$HOME/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log"
OUTPUT="$HOME/ssh-security-project/logs/attacks_$(date +%Y%m%d).json"

echo "[" > "$OUTPUT"

grep "login attempt" "$COWRIE_LOG" 2>/dev/null | tail -1000 | while IFS= read -r line; do
    TIMESTAMP=$(echo "$line" | awk '{print $1, $2}')
    IP=$(echo "$line" | grep -oP '(?<=from )[0-9.]+(?=:)')
    USER=$(echo "$line" | grep -oP 'login attempt \[\K[^/]+')
    PASS=$(echo "$line" | grep -oP 'login attempt \[[^]]+\] \(\K[^)]+')
    
    cat << JSON >> "$OUTPUT"
{
  "timestamp": "$TIMESTAMP",
  "source_ip": "$IP",
  "username": "$USER",
  "password": "$PASS",
  "event_type": "ssh_brute_force"
},
JSON
done

# Remove last comma and close array
sed -i '$ s/,$//' "$OUTPUT"
echo "]" >> "$OUTPUT"

echo "JSON export complete: $OUTPUT"
