#!/bin/bash
# Quick fix script for nginx configuration
# Run this on EC2 if nginx is showing default page

set -e

echo "🔧 Fixing nginx configuration..."

# Navigate to project
cd /opt/leaseledger

# Check if build exists
if [ ! -d "leaseledger-web/dist/leaseledger-web/browser" ]; then
    echo "❌ Angular build not found. Rebuilding..."
    cd leaseledger-web
    npm install
    ng build --configuration production
    cd ..
fi

# Verify build location
BUILD_DIR="leaseledger-web/dist/leaseledger-web/browser"
if [ -f "$BUILD_DIR/index.html" ]; then
    echo "✅ Build found at: $BUILD_DIR"
else
    echo "⚠️  Warning: index.html not found at $BUILD_DIR"
    echo "   Searching for build..."
    find leaseledger-web/dist -name "index.html" 2>/dev/null || echo "   Build not found - need to rebuild"
fi

# Update nginx config
echo "📝 Updating nginx configuration..."
sudo cp deploy/nginx.conf /etc/nginx/sites-available/leaseledger

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "_")
sudo sed -i "s/server_name _;/server_name $PUBLIC_IP;/g" /etc/nginx/sites-available/leaseledger

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Enable our site
sudo ln -sf /etc/nginx/sites-available/leaseledger /etc/nginx/sites-enabled/

# Test and restart
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "✅ Nginx fixed and restarted!"
    echo ""
    echo "🌐 Your app should now be at: http://$PUBLIC_IP"
else
    echo "❌ Nginx configuration error. Check: sudo nginx -t"
    exit 1
fi

