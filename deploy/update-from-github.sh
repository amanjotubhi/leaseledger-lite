#!/bin/bash
# Quick update script - pulls latest from GitHub and redeploys

set -e

EC2_KEY="$HOME/.ssh/ec2-keys/AmanUbhi.pem"
EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"
PROJECT_DIR="/opt/leaseledger"

if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Error: Key file not found at $EC2_KEY"
    exit 1
fi

echo "🔄 Updating LeaseLedger Lite from GitHub"
echo "========================================"
echo ""

echo "📥 Step 1: Pulling latest changes from GitHub..."
ssh -i "$EC2_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'ENDSSH'
cd /opt/leaseledger

# Pull latest changes
echo "Fetching latest from GitHub..."
git fetch origin
git pull origin main

echo "✅ Code updated!"
ENDSSH

echo ""
echo "🔧 Step 2: Rebuilding and restarting services..."
ssh -i "$EC2_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'ENDSSH'
cd /opt/leaseledger

# Update Python dependencies
echo "📦 Updating Python dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# Rebuild Angular app
echo "🏗️  Rebuilding Angular application..."
cd leaseledger-web
npm install
ng build --configuration production
cd ..

# Restart services
echo "🔄 Restarting services..."
sudo systemctl restart leaseledger-api
sudo systemctl reload nginx

echo "✅ Update complete!"
ENDSSH

echo ""
echo "✅ Application updated successfully!"
echo ""
echo "🌐 Check your app: http://3.144.125.246"
echo ""
echo "📊 Check status:"
echo "   ssh -i $EC2_KEY $EC2_HOST 'sudo systemctl status leaseledger-api'"

