# SSH Security System - Quick Reference

## Daily Operations

### Check System Status
```bash
~/ssh-security-project/scripts/status.sh
```

### View Attack Statistics
```bash
~/ssh-security-project/scripts/attack_stats.sh
```

### Run Analysis Report
```bash
~/ssh-security-project/scripts/splunk_analysis.sh
```

### Live Dashboard
```bash
~/ssh-security-project/scripts/dashboard.sh
```

### Run Tests
```bash
~/ssh-security-project/scripts/run_tests.sh
```

### Unblock an IP
```bash
~/ssh-security-project/scripts/unblock_ip.sh <IP_ADDRESS>
```

## Log Locations

- **Cowrie Logs**: `~/ssh-security-project/honeypot/cowrie/var/log/cowrie/cowrie.log`
- **Fail2ban Logs**: `/var/log/fail2ban.log`
- **SSH Auth Logs**: `/var/log/auth.log`
- **Attack Summary**: `~/ssh-security-project/logs/attack_summary.log`
- **Blocked IPs**: `~/ssh-security-project/logs/blocked_ips.log`

## Service Management

### Start/Stop/Restart Services
```bash
sudo systemctl start|stop|restart cowrie
sudo systemctl start|stop|restart fail2ban
sudo systemctl start|stop|restart sshd
```

### View Service Status
```bash
sudo systemctl status cowrie
sudo systemctl status fail2ban
sudo systemctl status sshd
```

## Fail2ban Commands

### Check jail status
```bash
sudo fail2ban-client status
sudo fail2ban-client status cowrie
sudo fail2ban-client status sshd
```

### Unban IP from fail2ban
```bash
sudo fail2ban-client unban <IP_ADDRESS>
```

## Port Information

- **Port 22**: Redirects to honeypot (via iptables)
- **Port 2222**: Cowrie honeypot
- **Port 2200**: Real SSH (key-based auth only)

## Emergency Access

If locked out, use Hyper-V console to access VM directly.
