# EC2 Deployment Guide for Your Instance

## Your EC2 Details
- **Host**: ec2-3-144-125-246.us-east-2.compute.amazonaws.com
- **User**: ubuntu
- **Key**: AmanUbhi.pem
- **IP**: 3.144.125.246

## Quick Deployment (Recommended)

### Option 1: Automated Script

1. **Make sure your key file is accessible:**
   ```bash
   # Copy key to project directory if needed
   cp /path/to/AmanUbhi.pem .
   chmod 400 AmanUbhi.pem
   ```

2. **Run deployment script:**
   ```bash
   cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"
   chmod +x deploy/deploy-to-ec2.sh
   ./deploy/deploy-to-ec2.sh
   ```

### Option 2: Manual Steps

#### Step 1: Initial Server Setup (First Time Only)

```bash
# SSH into EC2
ssh -i AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com

# Run initial setup
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip python3-venv nginx nodejs sqlite3 curl

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Angular CLI
sudo npm install -g @angular/cli

# Create application directory
sudo mkdir -p /opt/leaseledger
sudo chown ubuntu:ubuntu /opt/leaseledger
exit
```

#### Step 2: Upload Files

```bash
# From your local machine, in the project directory
cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"

# Upload files using SCP
scp -r -i AmanUbhi.pem \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='*.db' \
    . ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com:/opt/leaseledger/

# OR use rsync (better for updates)
rsync -avz --progress \
    -e "ssh -i AmanUbhi.pem" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='venv' \
    --exclude='*.db' \
    --exclude='leaseledger-web/dist' \
    --exclude='leaseledger-web/node_modules' \
    ./ ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com:/opt/leaseledger/
```

#### Step 3: Deploy on EC2

```bash
# SSH into EC2
ssh -i AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com

# Navigate to project
cd /opt/leaseledger

# Make scripts executable
chmod +x deploy/*.sh

# Run deployment
./deploy/quick-deploy.sh
```

#### Step 4: Configure Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Find your instance's security group
3. Add inbound rules:
   - **Type**: HTTP
   - **Port**: 80
   - **Source**: 0.0.0.0/0 (or your IP for security)

#### Step 5: Access Application

Open in browser:
```
http://3.144.125.246
```

## Troubleshooting

### Check API Status
```bash
ssh -i AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com
sudo systemctl status leaseledger-api
```

### Check API Logs
```bash
sudo journalctl -u leaseledger-api -f
# OR
tail -f /opt/leaseledger/logs/api.log
```

### Check Nginx
```bash
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### Test API Directly
```bash
curl http://localhost:8000/health
```

### Restart Services
```bash
sudo systemctl restart leaseledger-api
sudo systemctl restart nginx
```

### Check if Ports are Open
```bash
sudo netstat -tlnp | grep :8000  # API
sudo netstat -tlnp | grep :80    # Nginx
```

## Updating the Application

After making changes:

```bash
# From local machine
cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"

# Upload changes
rsync -avz --progress \
    -e "ssh -i AmanUbhi.pem" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.venv' \
    --exclude='*.db' \
    ./ ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com:/opt/leaseledger/

# Rebuild and restart
ssh -i AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com << 'ENDSSH'
cd /opt/leaseledger
source venv/bin/activate
pip install -r requirements.txt
cd leaseledger-web
npm install
ng build --configuration production
sudo systemctl restart leaseledger-api
sudo systemctl reload nginx
ENDSSH
```

## Security Notes

1. **Update Security Group**: Only allow HTTP (80) from IPs you trust in production
2. **Use HTTPS**: Set up SSL with Let's Encrypt for production
3. **Firewall**: Consider using AWS WAF for additional protection
4. **Backups**: Set up automated backups for the database

## SSL Setup (Optional)

```bash
# SSH into EC2
ssh -i AmanUbhi.pem ubuntu@ec2-3-144-125-246.us-east-2.compute.amazonaws.com

# Install certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate (replace with your domain if you have one)
sudo certbot --nginx -d your-domain.com

# Or use IP (requires DNS setup)
# Note: Let's Encrypt doesn't issue certs for IPs, you need a domain
```

## Monitoring

Set up CloudWatch or use simple monitoring:

```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU
top
```

