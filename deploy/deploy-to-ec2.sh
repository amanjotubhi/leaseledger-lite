#!/bin/bash
# Deployment script for your specific EC2 instance
# Run this from your local machine

set -e

EC2_KEY="AmanUbhi.pem"
EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"
PROJECT_DIR="/opt/leaseledger"

echo "🚀 Deploying LeaseLedger Lite to EC2"
echo "======================================"
echo ""

# Check if key file exists
if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Error: Key file '$EC2_KEY' not found in current directory"
    echo "   Make sure the .pem file is in the project root or provide full path"
    exit 1
fi

# Set proper permissions on key file
chmod 400 "$EC2_KEY"

echo "📦 Step 1: Uploading files to EC2..."
echo "   This may take a few minutes..."
rsync -avz --progress \
    -e "ssh -i $EC2_KEY" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='venv' \
    --exclude='*.db' \
    --exclude='leaseledger-web/dist' \
    --exclude='leaseledger-web/node_modules' \
    --exclude='.DS_Store' \
    ./ "$EC2_HOST:$PROJECT_DIR/"

echo ""
echo "🔧 Step 2: Running deployment on EC2..."
ssh -i "$EC2_KEY" "$EC2_HOST" << 'ENDSSH'
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
echo "📊 Check status:"
echo "   ssh -i $EC2_KEY $EC2_HOST 'sudo systemctl status leaseledger-api'"
echo ""
echo "📝 View logs:"
echo "   ssh -i $EC2_KEY $EC2_HOST 'sudo journalctl -u leaseledger-api -f'"

