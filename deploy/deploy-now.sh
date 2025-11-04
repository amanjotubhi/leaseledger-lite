#!/bin/bash
# Quick deployment script using the secure key location
# This uses the key from ~/.ssh/ec2-keys/ which is outside the project

set -e

EC2_KEY="$HOME/.ssh/ec2-keys/AmanUbhi.pem"
EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"
PROJECT_DIR="/opt/leaseledger"

# Check if key exists
if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Error: Key file not found at $EC2_KEY"
    echo ""
    echo "Setting up secure key location..."
    mkdir -p ~/.ssh/ec2-keys
    echo "Please copy your key:"
    echo "  cp /Users/amanjotubhi/Downloads/AmanUbhi.pem ~/.ssh/ec2-keys/"
    echo "  chmod 400 ~/.ssh/ec2-keys/AmanUbhi.pem"
    exit 1
fi

# Ensure proper permissions
chmod 400 "$EC2_KEY"

echo "🔒 Using secure key from: $EC2_KEY"
echo "✅ Key is outside project directory (secure)"
echo ""
echo "🚀 Deploying LeaseLedger Lite to EC2"
echo "======================================"
echo ""

# Get project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "📦 Step 1: Uploading files to EC2..."
echo "   This may take a few minutes..."
rsync -avz --progress \
    -e "ssh -i $EC2_KEY -o StrictHostKeyChecking=no" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='venv' \
    --exclude='*.db' \
    --exclude='*.pem' \
    --exclude='*.key' \
    --exclude='leaseledger-web/dist' \
    --exclude='leaseledger-web/node_modules' \
    --exclude='.DS_Store' \
    ./ "$EC2_HOST:$PROJECT_DIR/"

echo ""
echo "🔧 Step 2: Running deployment on EC2..."
ssh -i "$EC2_KEY" -o StrictHostKeyChecking=no "$EC2_HOST" << 'ENDSSH'
cd /opt/leaseledger
chmod +x deploy/*.sh
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

