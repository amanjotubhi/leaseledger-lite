#!/bin/bash
# Quick commands to publish to GitHub
# Run these commands after creating your GitHub repository

echo "🚀 Publishing LeaseLedger Lite to GitHub"
echo "========================================"
echo ""

# Replace YOUR_USERNAME with your actual GitHub username
GITHUB_USERNAME="YOUR_USERNAME"
REPO_NAME="leaseledger-lite"

echo "Step 1: Make sure you've created the repository on GitHub first!"
echo "   Go to: https://github.com/new"
echo "   Repository name: $REPO_NAME"
echo "   Don't initialize with README, .gitignore, or license"
echo ""
read -p "Press Enter when you've created the repository..."

echo ""
echo "Step 2: Adding remote repository..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

echo ""
echo "Step 3: Making initial commit..."
git commit -m "Initial commit: LeaseLedger Lite - Property Management Demo

- FastAPI backend with SQLite/Oracle support
- Angular frontend with multiple analytics dashboards
- AWS EC2 deployment scripts
- Complete documentation"

echo ""
echo "Step 4: Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Done! Your repository is now on GitHub!"
echo "   Visit: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "📝 Note: If prompted for password, use a Personal Access Token"
echo "   See GITHUB_SETUP.md for instructions"

