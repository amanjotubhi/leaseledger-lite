#!/bin/bash
# EC2 Setup Script for LeaseLedger Lite
# Run this on a fresh Ubuntu 22.04 EC2 instance

set -e

echo "🚀 Setting up LeaseLedger Lite on EC2..."

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and dependencies
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs npm sqlite3

# Install Node.js 20.x (for Angular)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Angular CLI globally
sudo npm install -g @angular/cli

# Create application directory
sudo mkdir -p /opt/leaseledger
sudo chown $USER:$USER /opt/leaseledger

# Create nginx user for web files
sudo useradd -r -s /bin/false leaseledger || true

# Install Oracle client libraries (optional, for Oracle mode)
sudo apt-get install -y libaio1 wget unzip

echo "✅ System setup complete!"
echo ""
echo "Next steps:"
echo "1. Upload your application files to /opt/leaseledger"
echo "2. Run: cd /opt/leaseledger && ./deploy/deploy.sh"
echo "3. Configure nginx: sudo cp deploy/nginx.conf /etc/nginx/sites-available/leaseledger"
echo "4. Enable site: sudo ln -s /etc/nginx/sites-available/leaseledger /etc/nginx/sites-enabled/"
echo "5. Restart nginx: sudo systemctl restart nginx"

