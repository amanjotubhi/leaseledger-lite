#!/bin/bash
# Deployment script that uses git clone from GitHub
# This ensures we're always deploying from the source of truth

set -e

EC2_KEY="$HOME/.ssh/ec2-keys/AmanUbhi.pem"
EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"
PROJECT_DIR="/opt/leaseledger"
GITHUB_REPO="https://github.com/amanjotubhi/leaseledger-lite.git"

# Check if key exists
if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Error: Key file not found at $EC2_KEY"
    exit 1
fi

echo "🚀 Deploying LeaseLedger Lite from GitHub"
echo "=========================================="
echo "Repository: $GITHUB_REPO"
echo ""

echo "🔧 Step 1: Setting up server and cloning from GitHub..."
ssh -i "$EC2_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << ENDSSH
set -e

echo "📦 Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs sqlite3 curl git

# Install Node.js 20.x if not present
if ! command -v node &> /dev/null || [ "\$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 20 ]; then
    echo "📦 Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Angular CLI if not present
if ! command -v ng &> /dev/null; then
    echo "📦 Installing Angular CLI..."
    sudo npm install -g @angular/cli
fi

# Create application directory
sudo mkdir -p $PROJECT_DIR
sudo chown ubuntu:ubuntu $PROJECT_DIR

# Clone or update repository
cd $PROJECT_DIR
if [ -d ".git" ]; then
    echo "🔄 Updating existing repository..."
    git pull origin main
else
    echo "📥 Cloning repository from GitHub..."
    git clone $GITHUB_REPO .
fi

# Make scripts executable
chmod +x deploy/*.sh

echo "✅ Repository ready!"
ENDSSH

echo ""
echo "🔧 Step 2: Running deployment on EC2..."
ssh -i "$EC2_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'ENDSSH'
cd /opt/leaseledger
./deploy/quick-deploy.sh
ENDSSH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your application should be available at:"
echo "   http://3.144.125.246"
echo ""
echo "📊 Quick commands:"
echo "   Check status: ssh -i $EC2_KEY $EC2_HOST 'sudo systemctl status leaseledger-api'"
echo "   View logs:    ssh -i $EC2_KEY $EC2_HOST 'sudo journalctl -u leaseledger-api -f'"
echo "   Test API:     curl http://3.144.125.246/api/health"
echo ""
echo "🔄 To update: Just push to GitHub and run this script again!"

