# GitHub-Based Deployment Guide

This deployment method uses Git to clone your repository directly on EC2, ensuring you're always deploying from your GitHub source of truth.

## 🎯 Benefits

- ✅ Always deploy from GitHub (source of truth)
- ✅ Easy updates - just push to GitHub and pull on EC2
- ✅ Version control - track all deployments
- ✅ No need to upload files manually
- ✅ Cleaner deployment process

## 📋 Prerequisites

1. **Push your code to GitHub first:**
   ```bash
   cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Verify your repository is public or you have SSH keys set up:**
   - Repository: https://github.com/amanjotubhi/leaseledger-lite

## 🚀 Initial Deployment

### Step 1: Run Deployment Script

```bash
cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"
./deploy/deploy-from-github.sh
```

This script will:
1. Install all dependencies on EC2
2. Clone your repository from GitHub
3. Set up Python virtual environment
4. Build Angular application
5. Configure systemd service
6. Set up nginx
7. Start all services

### Step 2: Configure Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Find your instance's security group
3. Add inbound rule:
   - **Type**: HTTP
   - **Port**: 80
   - **Source**: 0.0.0.0/0

### Step 3: Access Application

```
http://3.144.125.246
```

## 🔄 Updating Your Application

### Method 1: Automated Update (Recommended)

1. **Make changes locally and push to GitHub:**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

2. **Run update script:**
   ```bash
   ./deploy/update-from-github.sh
   ```

### Method 2: Manual Update

1. **SSH into EC2:**
   ```bash
   ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com
   ```

2. **Pull latest changes:**
   ```bash
   cd /opt/leaseledger
   git pull origin main
   ```

3. **Rebuild and restart:**
   ```bash
   # Update Python deps
   source venv/bin/activate
   pip install -r requirements.txt
   
   # Rebuild Angular
   cd leaseledger-web
   npm install
   ng build --configuration production
   cd ..
   
   # Restart services
   sudo systemctl restart leaseledger-api
   sudo systemctl reload nginx
   ```

## 📝 Workflow

### Development Workflow

```bash
# 1. Make changes locally
# ... edit files ...

# 2. Test locally
cd leaseledger-web
ng serve
# Test at http://localhost:4200

# 3. Commit and push to GitHub
git add .
git commit -m "Description of changes"
git push origin main

# 4. Deploy to EC2
./deploy/update-from-github.sh
```

## 🔍 Verification Commands

```bash
# Check if repository is cloned
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com \
  "cd /opt/leaseledger && git status"

# Check current commit
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com \
  "cd /opt/leaseledger && git log --oneline -1"

# Check service status
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com \
  "sudo systemctl status leaseledger-api"
```

## 🛠️ Troubleshooting

### If Git Clone Fails

```bash
# Check if repository is accessible
curl -I https://github.com/amanjotubhi/leaseledger-lite

# Try cloning manually
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com
cd /opt/leaseledger
rm -rf * .git  # Careful! Only if you want to start fresh
git clone https://github.com/amanjotubhi/leaseledger-lite.git .
```

### If Repository is Private

If your repository is private, you'll need to set up SSH keys or use a Personal Access Token:

**Option 1: SSH Keys (Recommended)**
```bash
# On EC2
ssh-keygen -t ed25519 -C "ec2-deploy"
cat ~/.ssh/id_ed25519.pub
# Add this to GitHub → Settings → SSH Keys
```

**Option 2: Personal Access Token**
```bash
# Clone with token
git clone https://YOUR_TOKEN@github.com/amanjotubhi/leaseledger-lite.git
```

### Force Update

If you need to completely reset:
```bash
ssh -i ~/.ssh/ec2-keys/AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com << 'ENDSSH'
cd /opt/leaseledger
git fetch origin
git reset --hard origin/main
./deploy/quick-deploy.sh
ENDSSH
```

## 📊 Comparison: rsync vs Git

| Feature | rsync Method | Git Method |
|---------|-------------|------------|
| Setup | Upload files | Clone repo |
| Updates | Re-upload | git pull |
| Version Control | No | Yes |
| Source of Truth | Local files | GitHub |
| Rollback | Manual | git checkout |
| **Recommended** | Development | **Production** |

## 🎯 Best Practices

1. **Always push to GitHub first** before deploying
2. **Tag releases** for important versions:
   ```bash
   git tag -a v1.0.0 -m "Production release"
   git push origin v1.0.0
   ```
3. **Use branches** for testing:
   ```bash
   git checkout -b staging
   # Test on staging environment
   git checkout main
   git merge staging
   ```
4. **Keep .gitignore updated** to exclude sensitive files
5. **Monitor deployments** with git log on EC2

## 🔐 Security Notes

- ✅ Repository is cloned, not uploaded
- ✅ No need to store keys in project
- ✅ Can use SSH keys for private repos
- ✅ All sensitive files remain in .gitignore

---

**Your deployment workflow:**
1. Develop locally
2. Test locally
3. Push to GitHub
4. Run `./deploy/update-from-github.sh`
5. Done! 🎉

