# AWS Authentication Setup Guide for GitHub Actions

**Complete Step-by-Step Guide for Mac Users**

---

## 🎯 What You'll Set Up

By the end of this guide, you'll have:
- ✅ AWS OIDC provider configured
- ✅ IAM role for GitHub Actions
- ✅ Proper permissions for ECS/ECR deployment
- ✅ **No long-lived credentials** (secure OIDC authentication)
- ✅ Ready to deploy from GitHub Actions

---

## 📋 Prerequisites

### 1. Verify AWS CLI
```bash
aws --version
# Should show: aws-cli/2.x.x

# Check you're logged in
aws sts get-caller-identity
# Should show your account info
```

If not configured:
```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: ap-south-1 (Mumbai)
# - Default output format: json
```

### 2. Check Permissions
Your AWS user needs these permissions:
- `iam:CreateOpenIDConnectProvider`
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:PutRolePolicy`

**Easiest**: Use an account with **AdministratorAccess** (for setup only)

### 3. GitHub Repository
- Have your GitHub repository created
- Know the full path: `owner/repository-name`
- Example: `npci-org/transfer-service`

---

## 🚀 Quick Setup (Automated - 5 Minutes)

### Option 1: Run Master Script (Recommended)

```bash
# 1. Download all setup scripts
# (You already have them from the package)

# 2. Make master script executable
chmod +x aws-setup-complete.sh

# 3. Run it!
./aws-setup-complete.sh
```

The script will:
1. Ask for your GitHub repository details
2. Create OIDC provider in AWS
3. Create IAM role with permissions
4. Verify everything works
5. Give you the secret to add to GitHub

**That's it!** Skip to "Add GitHub Secrets" section below.

---

## 🔧 Manual Setup (Step-by-Step - 15 Minutes)

If you prefer to understand each step:

### Step 1: Configuration (2 min)

```bash
# Make script executable
chmod +x aws-setup-config.sh

# Run configuration
./aws-setup-config.sh
```

You'll be asked:
- **GitHub Owner**: Your username or org (e.g., `npci-org`)
- **Repository Name**: Your repo name (e.g., `transfer-service`)

This creates `aws-config.env` with your settings.

### Step 2: Create OIDC Provider (3 min)

```bash
# Load configuration
source aws-config.env

# Make script executable
chmod +x aws-create-oidc-provider.sh

# Create OIDC provider
./aws-create-oidc-provider.sh
```

This creates the OIDC identity provider in your AWS account.

**What it does**:
- Creates OIDC provider: `token.actions.githubusercontent.com`
- Uses GitHub's thumbprint for security
- Allows GitHub Actions to authenticate

### Step 3: Create IAM Role (5 min)

```bash
# Make script executable
chmod +x aws-create-iam-role.sh

# Create IAM role
./aws-create-iam-role.sh
```

**What it does**:
- Creates role: `GitHubActions-NPCI-Role`
- Sets trust policy (only your repo can assume this role)
- Attaches policies:
  - `AmazonEC2ContainerRegistryPowerUser` (push/pull Docker images)
  - `AmazonECS_FullAccess` (deploy to ECS)
  - Additional inline policy (Load Balancer, Logs, Secrets)

### Step 4: Verify Setup (2 min)

```bash
# Make script executable
chmod +x aws-verify-setup.sh

# Verify everything
./aws-verify-setup.sh
```

You should see all green checkmarks! ✅

---

## 🔑 Add GitHub Secrets (3 Minutes)

### Copy Your Role ARN

After setup, you'll see:
```
Role ARN: arn:aws:iam::123456789012:role/GitHubActions-NPCI-Role
```

Copy this ARN!

### Add to GitHub

1. Go to your repository on GitHub
2. Click: **Settings** → **Secrets and variables** → **Actions**
3. Click: **New repository secret**

**Secret 1** (Required):
```
Name:  AWS_ROLE_ARN
Value: arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActions-NPCI-Role
```

**Secret 2** (Optional but recommended):
```
Name:  AWS_REGION
Value: ap-south-1
```

---

## ✅ Verify It Works

### Test Configuration

Your `aws-config.env` should contain:
```bash
export AWS_ACCOUNT_ID="123456789012"
export AWS_REGION="ap-south-1"
export GITHUB_OWNER="your-username"
export GITHUB_REPO="your-repo"
export GITHUB_REPO_FULL="your-username/your-repo"
export IAM_ROLE_NAME="GitHubActions-NPCI-Role"
export OIDC_PROVIDER_ARN="arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
export IAM_ROLE_ARN="arn:aws:iam::123456789012:role/GitHubActions-NPCI-Role"
```

### Test from Command Line

```bash
# Load config
source aws-config.env

# Check OIDC provider exists
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN"

# Check IAM role exists
aws iam get-role --role-name "$IAM_ROLE_NAME"

# Check trust policy
aws iam get-role \
  --role-name "$IAM_ROLE_NAME" \
  --query 'Role.AssumeRolePolicyDocument'
```

All commands should succeed without errors!

---

## 🧪 Test with GitHub Actions

Create a test workflow to verify authentication:

**.github/workflows/test-aws-auth.yml**:
```yaml
name: Test AWS Authentication

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  test-auth:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-south-1
      
      - name: Test AWS CLI
        run: |
          aws sts get-caller-identity
          echo "✅ AWS authentication successful!"
      
      - name: Test ECR Access
        run: |
          aws ecr describe-repositories || echo "No repositories yet"
          echo "✅ ECR access verified!"
```

Push this workflow and run it manually from the Actions tab.

If it succeeds → Your AWS auth is working! 🎉

---

## 🔒 Security Best Practices

### What Makes This Secure?

1. **No Long-Lived Credentials**
   - No access keys stored in GitHub
   - Temporary credentials generated on each run
   - Expire after 1 hour

2. **Least Privilege**
   - Role only has permissions needed for deployment
   - Trust policy limits to your specific repository
   - Can add branch restrictions if needed

3. **Audit Trail**
   - All actions logged in CloudTrail
   - Can see who assumed the role and when

### Enhanced Security (Optional)

Restrict to specific branches:

```bash
# Edit trust policy
nano trust-policy.json

# Change this line:
"token.actions.githubusercontent.com:sub": "repo:owner/repo:*"

# To (main branch only):
"token.actions.githubusercontent.com:sub": "repo:owner/repo:ref:refs/heads/main"

# Update role
aws iam update-assume-role-policy \
  --role-name GitHubActions-NPCI-Role \
  --policy-document file://trust-policy.json
```

---

## 🆘 Troubleshooting

### Issue: "AWS CLI not found"
```bash
# Install AWS CLI v2 on Mac
brew install awscli

# Verify
aws --version
```

### Issue: "Access Denied" when creating OIDC provider
```
Error: User is not authorized to perform: iam:CreateOpenIDConnectProvider
```

**Solution**: Your AWS user needs IAM admin permissions. Ask your AWS admin or:
```bash
# If you have permissions, attach policy to your user
aws iam attach-user-policy \
  --user-name YOUR_USERNAME \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
```

### Issue: "OIDC provider already exists"
```
An error occurred (EntityAlreadyExists)
```

**Solution**: This is OK! The script will detect and use the existing provider.

### Issue: "Role already exists"
```
An error occurred (EntityAlreadyExists)
```

**Solution**: This is OK! The script will update the trust policy.

### Issue: "Cannot find aws-config.env"
```
Error: aws-config.env not found
```

**Solution**: Run the configuration script first:
```bash
./aws-setup-config.sh
source aws-config.env
```

### Issue: GitHub Actions workflow fails with "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Causes**:
1. Wrong role ARN in GitHub secret
2. Repository name mismatch in trust policy
3. OIDC provider not configured

**Solution**:
```bash
# Verify secret
echo $IAM_ROLE_ARN
# Copy this EXACT value to GitHub secret

# Verify trust policy
aws iam get-role \
  --role-name GitHubActions-NPCI-Role \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'

# Should show your repository in the condition
```

---

## 📋 What Gets Created

### In AWS:

1. **OIDC Identity Provider**
   - URL: `token.actions.githubusercontent.com`
   - ARN: `arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com`

2. **IAM Role**
   - Name: `GitHubActions-NPCI-Role`
   - ARN: `arn:aws:iam::ACCOUNT_ID:role/GitHubActions-NPCI-Role`
   - Trust: Only your GitHub repository

3. **Attached Policies**
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonECS_FullAccess`
   - `GitHubActionsAdditionalPermissions` (inline)

### On Your Mac:

1. **Configuration Files**
   - `aws-config.env` - Your settings
   - `trust-policy.json` - IAM trust policy
   - `inline-policy.json` - Additional permissions

2. **Setup Scripts**
   - `aws-setup-config.sh`
   - `aws-create-oidc-provider.sh`
   - `aws-create-iam-role.sh`
   - `aws-verify-setup.sh`
   - `aws-setup-complete.sh` (master)

---

## 🎯 Next Steps

After AWS authentication is set up:

1. ✅ **AWS Auth Complete!**
2. 📝 Set up Azure authentication (run `azure-setup-complete.sh`)
3. 🏗️ Deploy infrastructure with Terraform
4. 🚀 Deploy your first application!

---

## 💡 Quick Reference

### View Configuration
```bash
cat aws-config.env
```

### View Role Details
```bash
source aws-config.env
aws iam get-role --role-name $IAM_ROLE_NAME
```

### View Attached Policies
```bash
source aws-config.env
aws iam list-attached-role-policies --role-name $IAM_ROLE_NAME
```

### Delete Setup (if needed)
```bash
source aws-config.env

# Detach policies
aws iam detach-role-policy \
  --role-name $IAM_ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

aws iam detach-role-policy \
  --role-name $IAM_ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# Delete inline policy
aws iam delete-role-policy \
  --role-name $IAM_ROLE_NAME \
  --policy-name GitHubActionsAdditionalPermissions

# Delete role
aws iam delete-role --role-name $IAM_ROLE_NAME

# Delete OIDC provider (optional - can reuse)
aws iam delete-open-id-connect-provider \
  --open-id-connect-provider-arn $OIDC_PROVIDER_ARN
```

---

## ✅ Success Checklist

- [ ] AWS CLI installed and configured
- [ ] `aws sts get-caller-identity` works
- [ ] `aws-setup-complete.sh` ran successfully
- [ ] All verification tests passed (green checkmarks)
- [ ] `AWS_ROLE_ARN` added to GitHub secrets
- [ ] Test workflow runs successfully
- [ ] Ready for Azure setup!

---

**You're all set with AWS! 🎉**

Next: Set up Azure authentication with the Azure setup scripts!
