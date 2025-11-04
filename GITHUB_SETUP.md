# GitHub Repository Setup Guide

Follow these steps to publish your LeaseLedger Lite project to GitHub.

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the **+** icon in the top right → **New repository**
3. Repository settings:
   - **Name**: `leaseledger-lite` (or your preferred name)
   - **Description**: "Property management demo app with FastAPI and Angular"
   - **Visibility**: Public (or Private if you prefer)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
4. Click **Create repository**

## Step 2: Connect Local Repository to GitHub

After creating the repository, GitHub will show you commands. Run these in your terminal:

```bash
cd "/Users/amanjotubhi/Aman Ubhi's Files/Coding Projects/LeaseLedger"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/leaseledger-lite.git

# Or if using SSH:
# git remote add origin git@github.com:YOUR_USERNAME/leaseledger-lite.git

# Verify remote
git remote -v
```

## Step 3: Make Initial Commit

```bash
# Check what will be committed
git status

# Add all files
git add .

# Make initial commit
git commit -m "Initial commit: LeaseLedger Lite - Property Management Demo

- FastAPI backend with SQLite/Oracle support
- Angular frontend with multiple analytics dashboards
- AWS EC2 deployment scripts
- Complete documentation"

# Verify commit
git log --oneline
```

## Step 4: Push to GitHub

```bash
# Push to main branch
git branch -M main
git push -u origin main

# If prompted for credentials, use:
# - Username: Your GitHub username
# - Password: Use a Personal Access Token (not your password)
```

## Step 5: Create Personal Access Token (if needed)

If you're asked for a password:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click **Generate new token (classic)**
3. Give it a name: "LeaseLedger Lite"
4. Select scopes: **repo** (full control of private repositories)
5. Click **Generate token**
6. **Copy the token immediately** (you won't see it again)
7. Use this token as your password when pushing

## Step 6: Verify on GitHub

1. Go to your repository on GitHub
2. You should see all your files
3. The README should render with nice formatting
4. Check that all files are present

## Step 7: Add Topics/Tags (Optional)

On your GitHub repository page:
1. Click the gear icon (⚙️) next to "About"
2. Add topics:
   - `fastapi`
   - `angular`
   - `property-management`
   - `yardi`
   - `python`
   - `typescript`
   - `aws`
   - `demo`

## Step 8: Update README (Optional)

Edit the README.md to:
- Replace `YOUR_USERNAME` with your actual GitHub username
- Update author information
- Add any additional details about your project

## Troubleshooting

### If you get "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/leaseledger-lite.git
```

### If you need to update the remote URL
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/leaseledger-lite.git
```

### If files are too large
Check if you accidentally committed:
- `node_modules/` (should be in .gitignore)
- `*.db` files (should be in .gitignore)
- `venv/` or `.venv/` (should be in .gitignore)

Remove them:
```bash
git rm -r --cached node_modules/
git rm --cached *.db
git commit -m "Remove ignored files"
```

### Common Git Commands

```bash
# Check status
git status

# View changes
git diff

# Add specific files
git add filename.txt

# Commit changes
git commit -m "Your commit message"

# Push changes
git push

# Pull latest changes
git pull

# View commit history
git log --oneline --graph
```

## Next Steps

After publishing:
1. ✅ Share the repository link on LinkedIn
2. ✅ Add it to your portfolio
3. ✅ Mention it in your Yardi interview
4. ✅ Consider adding a demo video or screenshots
5. ✅ Keep it updated with improvements

## Making Future Updates

```bash
# Make changes to your code
# ...

# Stage changes
git add .

# Commit
git commit -m "Description of your changes"

# Push
git push
```

## Adding a License

If you want to add a license:

1. Go to your repository on GitHub
2. Click "Add file" → "Create new file"
3. Name it `LICENSE`
4. GitHub will offer to add a license template
5. Choose one (MIT is popular for open source)

---

🎉 Congratulations! Your project is now on GitHub!

