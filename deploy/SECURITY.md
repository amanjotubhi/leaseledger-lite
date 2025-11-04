# Security Guide for EC2 Deployment

## 🔒 Protecting Your PEM Key File

### ✅ Your Key is Already Protected

Your `.gitignore` file includes `*.pem`, which means:
- ✅ PEM files will **NEVER** be committed to Git
- ✅ PEM files will **NEVER** be pushed to GitHub
- ✅ Your key is safe from public exposure

### Verify Your Key is Protected

```bash
# Check if PEM file is ignored
git status --ignored | grep pem

# Try to add it (should be ignored)
git add AmanUbhi.pem
git status  # Should show nothing added

# Verify it's in .gitignore
grep -i pem .gitignore
```

### Best Practices

#### 1. **File Permissions**
Always set restrictive permissions on your key file:
```bash
chmod 400 AmanUbhi.pem
```
This makes it readable only by you.

#### 2. **Never Commit Keys**
✅ **DO:**
- Keep `.pem` files in `.gitignore`
- Use environment variables for sensitive data
- Store keys outside the project directory

❌ **DON'T:**
- Commit `.pem` files to Git
- Share keys in chat/messages
- Upload keys to cloud storage (unless encrypted)

#### 3. **Alternative: Use Key Directory Outside Project**
```bash
# Store keys in a secure location outside the project
mkdir -p ~/.ssh/ec2-keys
cp AmanUbhi.pem ~/.ssh/ec2-keys/
chmod 400 ~/.ssh/ec2-keys/AmanUbhi.pem

# Update deployment script to use absolute path
# Or use environment variable
export EC2_KEY_PATH="$HOME/.ssh/ec2-keys/AmanUbhi.pem"
```

#### 4. **Use SSH Config (Recommended)**
Create `~/.ssh/config`:
```
Host leaseledger-ec2
    HostName ec2-3-144-125-246.us-east-2.compute.amazonaws.com
    User ubuntu
    IdentityFile ~/.ssh/ec2-keys/AmanUbhi.pem
    IdentitiesOnly yes
```

Then connect simply:
```bash
ssh leaseledger-ec2
```

#### 5. **Use AWS Systems Manager (Production)**
For production, use AWS Systems Manager Parameter Store:
```bash
# Store key securely in AWS
aws ssm put-parameter \
    --name "/leaseledger/ec2-key" \
    --value "$(cat AmanUbhi.pem)" \
    --type "SecureString"

# Retrieve when needed
aws ssm get-parameter \
    --name "/leaseledger/ec2-key" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text > /tmp/key.pem
```

## 🔐 Security Checklist

Before deploying:

- [ ] Key file has 400 permissions (`chmod 400`)
- [ ] Key is NOT tracked by Git (check `git status`)
- [ ] `.gitignore` includes `*.pem`
- [ ] Key is stored in a secure location
- [ ] Never share key via insecure channels
- [ ] Consider using SSH config file
- [ ] Rotate keys periodically (every 90 days)

## 🚨 If You Accidentally Committed a Key

If you accidentally committed a key to Git:

### 1. Remove from Git (but keep local file)
```bash
git rm --cached AmanUbhi.pem
git commit -m "Remove sensitive key file"
git push
```

### 2. Rotate the Key Immediately
- Go to AWS Console → EC2 → Key Pairs
- Create a new key pair
- Update your EC2 instance with the new key
- Delete the old key from AWS

### 3. Check Git History
```bash
# Check if key was in previous commits
git log --all --full-history -- AmanUbhi.pem

# If found, consider rewriting history (advanced)
# Or just accept that old commits contain it and rotate keys
```

## 📝 Secure Deployment Script

Create a secure deployment script that uses environment variables:

```bash
#!/bin/bash
# deploy-secure.sh

# Load key from environment or secure location
EC2_KEY="${EC2_KEY_PATH:-$HOME/.ssh/ec2-keys/AmanUbhi.pem}"

if [ ! -f "$EC2_KEY" ]; then
    echo "❌ Key file not found at $EC2_KEY"
    echo "   Set EC2_KEY_PATH environment variable or place key in ~/.ssh/ec2-keys/"
    exit 1
fi

# Ensure proper permissions
chmod 400 "$EC2_KEY"

# Rest of deployment...
```

## 🛡️ Additional Security Measures

### 1. Use IAM Roles Instead of Keys (Best Practice)
For production, use IAM roles attached to EC2 instances:
- No keys needed on the instance
- Automatic credential rotation
- Better security

### 2. Enable AWS CloudTrail
Monitor all API calls and key usage.

### 3. Use AWS Secrets Manager
For storing sensitive configuration:
```bash
aws secretsmanager create-secret \
    --name leaseledger/db-password \
    --secret-string "your-password"
```

### 4. Network Security
- Use Security Groups to restrict access
- Only allow SSH from your IP
- Use VPN for production access
- Enable VPC for network isolation

## ✅ Verification Commands

```bash
# 1. Check if PEM is ignored
git check-ignore -v AmanUbhi.pem

# 2. Verify permissions
ls -la AmanUbhi.pem  # Should show -r-------- (400)

# 3. Check Git history for any keys
git log --all --full-history --source -- "*pem" "*key"

# 4. Verify .gitignore
cat .gitignore | grep -i pem
```

## 📚 Resources

- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Git Security Guide](https://git-scm.com/docs/gitignore)
- [SSH Key Management](https://www.ssh.com/ssh/key/)

---

**Remember**: Your key is safe as long as:
1. It's in `.gitignore` ✅ (already done)
2. It has proper permissions (400) ✅
3. You never commit it to Git ✅
4. You never share it publicly ✅

