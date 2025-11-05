#!/bin/bash
# Verification script to check deployment status
# Run this on EC2 or via SSH

set -e

echo "🔍 Verifying LeaseLedger Lite Deployment"
echo "========================================"
echo ""

# Check if we're on EC2 or local
if [ -d "/opt/leaseledger" ]; then
    PROJECT_DIR="/opt/leaseledger"
    ON_EC2=true
else
    PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."
    ON_EC2=false
fi

cd "$PROJECT_DIR"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

# Check Angular build
echo "🏗️  Checking Angular build..."
BUILD_DIR="leaseledger-web/dist/leaseledger-web/browser"
if [ -f "$BUILD_DIR/index.html" ]; then
    echo "✅ Build found at: $BUILD_DIR"
    echo "   Files: $(ls -1 $BUILD_DIR | wc -l) files"
else
    echo "❌ Build NOT found at: $BUILD_DIR"
    echo "   Searching for build..."
    find leaseledger-web/dist -name "index.html" 2>/dev/null || echo "   ⚠️  No build found - need to run: cd leaseledger-web && ng build --configuration production"
fi

echo ""

# Check nginx
echo "🌐 Checking nginx..."
if command -v nginx &> /dev/null; then
    if sudo nginx -t 2>&1 | grep -q "successful"; then
        echo "✅ Nginx configuration is valid"
    else
        echo "❌ Nginx configuration has errors"
        sudo nginx -t
    fi
    
    if [ -f "/etc/nginx/sites-enabled/leaseledger" ]; then
        echo "✅ LeaseLedger nginx config is enabled"
    else
        echo "❌ LeaseLedger nginx config NOT enabled"
        echo "   Run: sudo ln -s /etc/nginx/sites-available/leaseledger /etc/nginx/sites-enabled/"
    fi
    
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        echo "⚠️  Default nginx site is still enabled (should be removed)"
    else
        echo "✅ Default nginx site is removed"
    fi
else
    echo "❌ Nginx is not installed"
fi

echo ""

# Check API service
echo "⚙️  Checking API service..."
if [ "$ON_EC2" = true ]; then
    if sudo systemctl is-active --quiet leaseledger-api; then
        echo "✅ API service is running"
    else
        echo "❌ API service is NOT running"
        echo "   Check: sudo systemctl status leaseledger-api"
    fi
    
    # Check if API responds
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ API is responding at http://localhost:8000"
        curl -s http://localhost:8000/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8000/health
    else
        echo "❌ API is not responding"
    fi
fi

echo ""

# Check file permissions
echo "🔐 Checking permissions..."
if [ -d "$BUILD_DIR" ]; then
    if [ -r "$BUILD_DIR/index.html" ]; then
        echo "✅ Build files are readable"
    else
        echo "❌ Build files are not readable"
        echo "   Run: sudo chown -R www-data:www-data $BUILD_DIR"
    fi
fi

echo ""
echo "📊 Summary:"
echo "   - Build: $([ -f "$BUILD_DIR/index.html" ] && echo "✅" || echo "❌")"
echo "   - Nginx: $([ -f "/etc/nginx/sites-enabled/leaseledger" ] && echo "✅" || echo "❌")"
if [ "$ON_EC2" = true ]; then
    echo "   - API: $(sudo systemctl is-active --quiet leaseledger-api && echo "✅" || echo "❌")"
fi

