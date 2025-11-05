# Deployment Guide - LeaseLedger Lite

## 🚀 GitHub-Based Deployment (Recommended)

This method uses Git to clone your repository directly on EC2, ensuring you always deploy from GitHub.

### Step 1: Push Latest Code to GitHub

```bash
cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"
git add .
git commit -m "Your changes"
git push origin main
```

### Step 2: Deploy to EC2

Run the deployment script from your local machine:

```bash
./deploy/deploy-from-github.sh
```

This will:
1. ✅ Install all dependencies on EC2
2. ✅ Clone your repository from GitHub
3. ✅ Set up Python virtual environment
4. ✅ Build Angular application
5. ✅ Configure systemd service
6. ✅ Set up nginx
7. ✅ Start all services

### Step 3: Configure Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Add inbound rule: HTTP (port 80) from 0.0.0.0/0

### Step 4: Access Application

```
http://3.144.125.246
```

## 🔄 Updating Your Application

After making changes:

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

2. **Update on EC2:**
   ```bash
   ./deploy/update-from-github.sh
   ```

## 📚 Detailed Documentation

- **GitHub Deployment**: See `deploy/GITHUB_DEPLOYMENT.md`
- **Security Guide**: See `deploy/SECURITY.md`
- **AWS Deployment**: See `deploy/AWS_DEPLOYMENT.md`

## 🎯 Quick Commands

```bash
# Initial deployment
./deploy/deploy-from-github.sh

# Update application
./deploy/update-from-github.sh

# SSH into EC2
./deploy/ssh-ec2.sh

# Check status
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com \
  "sudo systemctl status leaseledger-api"
```

