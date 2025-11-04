#!/bin/bash
# Quick deployment script - runs all setup steps
# Run this on your EC2 instance after uploading files

set -e

echo "🚀 Quick Deploy LeaseLedger Lite on EC2"
echo "========================================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please don't run as root. Use sudo when needed."
    exit 1
fi

# Install dependencies
echo ""
echo "📦 Step 1: Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs sqlite3 curl

# Install Node.js 20.x
if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 20 ]; then
    echo "📦 Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Angular CLI
if ! command -v ng &> /dev/null; then
    echo "📦 Installing Angular CLI..."
    sudo npm install -g @angular/cli
fi

# Navigate to project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo ""
echo "📦 Step 2: Setting up Python environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "🏗️  Step 3: Building Angular application..."
cd leaseledger-web

# Update API service to use relative paths
if [ -f "src/app/api.service.ts" ]; then
    # Use relative API path for nginx proxy
    sed -i "s|base = 'http://localhost:8000'|base = '/api'|g" src/app/api.service.ts
fi

npm install
ng build --configuration production
cd ..

# Create directories
mkdir -p logs data
chmod +x deploy/*.sh

echo ""
echo "⚙️  Step 4: Configuring systemd service..."
sudo cp deploy/leaseledger-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable leaseledger-api
sudo systemctl restart leaseledger-api

echo ""
echo "🌐 Step 5: Configuring nginx..."
sudo cp deploy/nginx.conf /etc/nginx/sites-available/leaseledger

# Get public IP or use placeholder
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "_")
sudo sed -i "s/server_name _;/server_name $PUBLIC_IP;/g" /etc/nginx/sites-available/leaseledger

# Enable site
sudo ln -sf /etc/nginx/sites-available/leaseledger /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx config
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "🌐 Access your application at:"
echo "   http://$PUBLIC_IP"
echo ""
echo "📊 Check service status:"
echo "   sudo systemctl status leaseledger-api"
echo ""
echo "📝 View logs:"
echo "   sudo journalctl -u leaseledger-api -f"
echo "   tail -f /opt/leaseledger/logs/api.log"

