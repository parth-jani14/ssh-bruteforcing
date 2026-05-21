#!/bin/bash

echo "=============================================="
echo "SSH Security System - EC2 Setup Script"
echo "=============================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "Please run as normal user with sudo access, not as root"
   exit 1
fi

# Update system
echo "[1/10] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install prerequisites
echo "[2/10] Installing prerequisites..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    authbind \
    fail2ban \
    iptables-persistent \
    sshpass \
    wget \
    curl \
    net-tools

# Create project structure
echo "[3/10] Creating project structure..."
mkdir -p ~/ssh-security-project/{honeypot,logs,scripts}

# Setup Cowrie
echo "[4/10] Setting up Cowrie honeypot..."
cd ~/ssh-security-project/honeypot
git clone https://github.com/cowrie/cowrie.git
cd cowrie

# Create virtual environment
python3 -m venv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Copy config
cp etc/cowrie.cfg.dist etc/cowrie.cfg

# Configure authbind for port 22
sudo touch /etc/authbind/byport/22
sudo chown $(whoami):$(whoami) /etc/authbind/byport/22
sudo chmod 770 /etc/authbind/byport/22

deactivate

# Setup port forwarding
echo "[5/10] Configuring port forwarding..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
sudo netfilter-persistent save

# Install Cowrie service
echo "[6/10] Installing Cowrie systemd service..."
sudo cp ~/ssh-security-project/config/cowrie.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cowrie
sudo systemctl start cowrie

# Setup fail2ban
echo "[7/10] Configuring fail2ban..."
sudo cp ~/ssh-security-project/config/cowrie-filter.conf /etc/fail2ban/filter.d/cowrie.conf
sudo cp ~/ssh-security-project/config/cowrie-jail.conf /etc/fail2ban/jail.d/cowrie.conf
sudo cp ~/ssh-security-project/config/sshd-jail.conf /etc/fail2ban/jail.d/sshd.conf
sudo cp ~/ssh-security-project/config/hostsdenyadd.conf /etc/fail2ban/action.d/hostsdenyadd.conf
sudo cp ~/ssh-security-project/config/fail2ban-jail.local /etc/fail2ban/jail.local 2>/dev/null

# Create iptables chain
sudo iptables -N BLOCKED_IPS 2>/dev/null
sudo iptables -A INPUT -j BLOCKED_IPS 2>/dev/null
sudo netfilter-persistent save

sudo systemctl restart fail2ban

# Setup passwordless sudo for monitoring
echo "[8/10] Configuring passwordless sudo for monitoring..."
sudo tee /etc/sudoers.d/cowrie-monitor > /dev/null <<SUDO
$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/tee -a /etc/hosts.deny
$(whoami) ALL=(ALL) NOPASSWD: /usr/sbin/iptables
$(whoami) ALL=(ALL) NOPASSWD: /usr/sbin/netfilter-persistent
$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/fail2ban-client
$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/grep * /var/log/fail2ban.log
SUDO
sudo chmod 0440 /etc/sudoers.d/cowrie-monitor

# Make scripts executable
echo "[9/10] Setting script permissions..."
chmod +x ~/ssh-security-project/scripts/*.sh

# Setup cron jobs
echo "[10/10] Setting up automated tasks..."
(crontab -l 2>/dev/null; echo "*/5 * * * * $HOME/ssh-security-project/scripts/monitor_attacks.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * * $HOME/ssh-security-project/scripts/splunk_analysis.sh >> $HOME/ssh-security-project/logs/daily_report.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 */6 * * * $HOME/ssh-security-project/scripts/export_json.sh") | crontab -

echo ""
echo "=============================================="
echo "Setup Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "1. Configure SSH hardening (see documentation)"
echo "2. Setup SSH keys for port 2200 access"
echo "3. Run: ~/ssh-security-project/scripts/run_tests.sh"
echo ""
