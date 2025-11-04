#!/bin/bash
# Secure deployment script that uses environment variables or secure key location
# This ensures keys are never in the project directory

set -e

# Default key locations (in order of preference)
KEY_LOCATIONS=(
    "$EC2_KEY_PATH"                          # Environment variable
    "$HOME/.ssh/ec2-keys/AmanUbhi.pem"       # Secure home directory
    "$HOME/.ssh/AmanUbhi.pem"                # Standard SSH directory
    "./AmanUbhi.pem"                         # Current directory (fallback)
)

EC2_HOST="ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com"
PROJECT_DIR="/opt/leaseledger"

# Find the key file
EC2_KEY=""
for location in "${KEY_LOCATIONS[@]}"; do
    if [ -n "$location" ] && [ -f "$location" ]; then
        EC2_KEY="$location"
        break
    fi
done

# Check if key was found
if [ -z "$EC2_KEY" ]; then
    echo "❌ Error: EC2 key file not found!"
    echo ""
    echo "Please do one of the following:"
    echo "  1. Set EC2_KEY_PATH environment variable:"
    echo "     export EC2_KEY_PATH=/path/to/AmanUbhi.pem"
    echo ""
    echo "  2. Place key in secure location:"
    echo "     mkdir -p ~/.ssh/ec2-keys"
    echo "     cp AmanUbhi.pem ~/.ssh/ec2-keys/"
    echo "     chmod 400 ~/.ssh/ec2-keys/AmanUbhi.pem"
    echo ""
    echo "  3. Or place in current directory (not recommended for production)"
    exit 1
fi

echo "🔒 Using key from: $EC2_KEY"

# Ensure proper permissions
chmod 400 "$EC2_KEY" 2>/dev/null || {
    echo "⚠️  Warning: Could not set permissions on key file"
    echo "   Run: chmod 400 $EC2_KEY"
}

# Verify key is not in Git
if git rev-parse --git-dir > /dev/null 2>&1; then
    if git check-ignore -q "$EC2_KEY" 2>/dev/null || [[ "$EC2_KEY" == *".ssh"* ]]; then
        echo "✅ Key is properly ignored by Git"
    else
        echo "⚠️  Warning: Key file may not be in .gitignore"
        echo "   Make sure *.pem is in your .gitignore file"
    fi
fi

echo ""
echo "🚀 Deploying LeaseLedger Lite to EC2"
echo "======================================"
echo ""

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
echo "📊 Check status:"
echo "   ssh -i $EC2_KEY $EC2_HOST 'sudo systemctl status leaseledger-api'"
echo ""
echo "📝 View logs:"
echo "   ssh -i $EC2_KEY $EC2_HOST 'sudo journalctl -u leaseledger-api -f'"

