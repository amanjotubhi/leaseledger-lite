# AWS EC2 Deployment Guide for LeaseLedger Lite

This guide will help you deploy LeaseLedger Lite on an AWS EC2 instance.

## Prerequisites

- AWS account with EC2 access
- EC2 instance running Ubuntu 22.04 LTS
- SSH access to your EC2 instance
- Security group configured to allow:
  - SSH (port 22) from your IP
  - HTTP (port 80) from anywhere (0.0.0.0/0)
  - HTTPS (port 443) from anywhere (0.0.0.0/0) - if using SSL

## Step 1: Launch EC2 Instance

1. Go to AWS EC2 Console
2. Launch Instance:
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance Type**: t3.small or t3.medium (minimum 2GB RAM)
   - **Key Pair**: Create or select an existing key pair
   - **Security Group**: Create new with rules:
     - SSH: Port 22 from My IP
     - HTTP: Port 80 from Anywhere
   - **Storage**: 20GB minimum

## Step 2: Connect to EC2 Instance

```bash
# Replace with your key file and EC2 public IP
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

## Step 3: Initial Server Setup

Run the setup script on your EC2 instance:

```bash
# Clone or upload your project
git clone YOUR_REPO_URL /opt/leaseledger
# OR upload files via SCP:
# scp -r -i your-key.pem /path/to/LeaseLedger ubuntu@YOUR_EC2_IP:/opt/

cd /opt/leaseledger

# Make scripts executable
chmod +x deploy/*.sh

# Run initial setup
sudo ./deploy/ec2-setup.sh
```

## Step 4: Deploy Application

```bash
cd /opt/leaseledger

# Run deployment script
./deploy/deploy.sh
```

## Step 5: Configure Systemd Service

```bash
# Copy service file
sudo cp deploy/leaseledger-api.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service (starts on boot)
sudo systemctl enable leaseledger-api

# Start service
sudo systemctl start leaseledger-api

# Check status
sudo systemctl status leaseledger-api
```

## Step 6: Configure Nginx

```bash
# Copy nginx configuration
sudo cp deploy/nginx.conf /etc/nginx/sites-available/leaseledger

# Replace placeholder with your domain or IP
sudo nano /etc/nginx/sites-available/leaseledger
# Change: server_name _; to server_name your-domain.com;

# Enable site
sudo ln -s /etc/nginx/sites-available/leaseledger /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## Step 7: Update Security Group

1. Go to EC2 Console → Security Groups
2. Edit inbound rules:
   - Add HTTP (port 80) from 0.0.0.0/0
   - Add HTTPS (port 443) if using SSL

## Step 8: Update Angular API Base URL

Before building, update the API URL in Angular:

```bash
cd /opt/leaseledger/leaseledger-web
nano src/app/api.service.ts

# Change:
# base = 'http://localhost:8000';
# To:
# base = 'http://YOUR_EC2_PUBLIC_IP';  # or use your domain
# Or better: base = '/api';  # Use relative path for nginx proxy

# Rebuild
ng build --configuration production
```

## Step 9: Verify Deployment

1. Check API is running:
   ```bash
   curl http://localhost:8000/health
   ```

2. Check nginx is serving files:
   ```bash
   curl http://localhost
   ```

3. Access from browser:
   ```
   http://YOUR_EC2_PUBLIC_IP
   ```

## Optional: Set Up SSL with Let's Encrypt

```bash
# Install certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Certbot will automatically configure nginx
```

## Troubleshooting

### Check API logs:
```bash
sudo journalctl -u leaseledger-api -f
# OR
tail -f /opt/leaseledger/logs/api.log
```

### Check nginx logs:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Restart services:
```bash
sudo systemctl restart leaseledger-api
sudo systemctl restart nginx
```

### Check if ports are listening:
```bash
sudo netstat -tlnp | grep :8000  # API
sudo netstat -tlnp | grep :80    # Nginx
```

## Updating the Application

After making changes:

```bash
cd /opt/leaseledger
git pull  # or upload new files

# Rebuild frontend
cd leaseledger-web
ng build --configuration production

# Restart API
sudo systemctl restart leaseledger-api

# Reload nginx
sudo systemctl reload nginx
```

## Environment Variables

Edit `/etc/systemd/system/leaseledger-api.service` to add environment variables:

```ini
[Service]
Environment="DB_DRIVER=sqlite"
Environment="DB_PATH=/opt/leaseledger/data/leaseledger.db"
Environment="ORACLE_DSN=your-dsn"  # If using Oracle
Environment="ORACLE_USER=your-user"
Environment="ORACLE_PASSWORD=your-password"
```

Then:
```bash
sudo systemctl daemon-reload
sudo systemctl restart leaseledger-api
```

## Backup

Create a backup script:

```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /opt/backups/leaseledger_$DATE.tar.gz \
    /opt/leaseledger/data \
    /opt/leaseledger/app/leaseledger.db
```

## Security Recommendations

1. **Use SSL/HTTPS**: Always use Let's Encrypt for production
2. **Firewall**: Use AWS Security Groups properly
3. **Regular Updates**: `sudo apt-get update && sudo apt-get upgrade`
4. **Database Backups**: Set up automated backups
5. **Monitor Logs**: Set up CloudWatch or similar monitoring

## Cost Optimization

- Use t3.micro for testing (free tier eligible)
- Use t3.small for production (low cost)
- Consider using AWS Lightsail for simpler pricing
- Enable CloudWatch basic monitoring (free tier)

