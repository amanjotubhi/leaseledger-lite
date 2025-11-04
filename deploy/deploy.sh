#!/bin/bash
# Deployment script for LeaseLedger Lite
# Run from project root directory

set -e

echo "🚀 Deploying LeaseLedger Lite..."

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Build Angular frontend
echo "🏗️  Building Angular application..."
cd leaseledger-web

# Install Node dependencies
npm install

# Update API base URL for production
if [ -f "src/app/api.service.ts" ]; then
    # Get EC2 instance IP or use environment variable
    API_URL="${API_URL:-http://localhost:8000}"
    sed -i "s|base = 'http://localhost:8000'|base = '${API_URL}'|g" src/app/api.service.ts
fi

# Build for production
ng build --configuration production

cd ..

# Create necessary directories
mkdir -p logs
mkdir -p data

# Set permissions
chmod +x deploy/start-api.sh

echo "✅ Deployment complete!"
echo ""
echo "To start the application:"
echo "  sudo systemctl start leaseledger-api"
echo ""
echo "To check status:"
echo "  sudo systemctl status leaseledger-api"

