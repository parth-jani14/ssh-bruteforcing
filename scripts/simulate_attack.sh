#!/bin/bash

echo "==================================="
echo "SSH Attack Simulation"
echo "==================================="
echo ""

TARGET="localhost"
PORT="2222"
ATTEMPTS=5

echo "Simulating brute-force attack on honeypot..."
echo "Target: $TARGET:$PORT"
echo "Attempts: $ATTEMPTS"
echo ""

for i in $(seq 1 $ATTEMPTS); do
    echo "Attempt $i: Trying root/password$i"
    sshpass -p "password$i" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $PORT root@$TARGET "echo 'test'" 2>/dev/null &
    sleep 1
done

wait

echo ""
echo "Attack simulation complete!"
echo "Check fail2ban status in 30 seconds..."
