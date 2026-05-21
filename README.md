# SSH Security & Honeypot System

Complete SSH security system with Cowrie honeypot, fail2ban, automated blocking, and Splunk integration.

## Features
- SSH Honeypot (Cowrie) on ports 22 & 2222
- Hardened SSH on port 2200
- Automated attack detection & blocking (fail2ban)
- Log analysis & monitoring scripts
- Splunk Universal Forwarder integration
- Real-time dashboard

## Architecture
- **Port 22**: Redirects to honeypot (iptables)
- **Port 2222**: Cowrie honeypot
- **Port 2200**: Real SSH (key-based auth only)

## Quick Start
```bash
# Clone repository
git clone <your-repo-url>
cd ssh-security-project

# Run automated setup
chmod +x setup.sh
./setup.sh
```

## Scripts
- `monitor_attacks.sh` - Monitor and block attackers
- `attack_stats.sh` - Display attack statistics
- `status.sh` - System status check
- `dashboard.sh` - Live monitoring dashboard
- `run_tests.sh` - Test suite

## Documentation
See `QUICK_REFERENCE.md` for daily operations commands.

## Requirements
- Ubuntu 22.04 LTS
- 1GB RAM minimum
- Python 3.10+
- Root/sudo access

## Author
Your Name

## License
MIT
