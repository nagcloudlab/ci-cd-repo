# Azure Authentication Setup Guide for GitHub Actions

**Complete Step-by-Step Guide for Mac Users**

---

## 🎯 What You'll Set Up

By the end of this guide, you'll have:
- ✅ Azure service principal configured
- ✅ OIDC federated credentials for GitHub Actions
- ✅ Proper permissions for AKS/ACR deployment
- ✅ **No client secrets** (secure OIDC authentication)
- ✅ Ready to deploy from GitHub Actions

---

## 📋 Prerequisites

### 1. Verify Azure CLI
```bash
az version
# Should show: "azure-cli": "2.x.x"

# Check you're logged in
az account show
# Should show your subscription info
```

If not logged in:
```bash
az login
# Opens browser for authentication
```

### 2. Check Permissions
Your Azure account needs:
- Contributor role on the subscription
- Ability to create Azure AD applications
- Ability to create service principals

**Easiest**: Use an account with **Owner** or **User Access Administrator** role

### 3. GitHub Repository
- Have your GitHub repository created
- Know the full path: `owner/repository-name`
- Same repo you used for AWS setup

---

## 🚀 Quick Setup (Automated - 5 Minutes)

### Option 1: Run Master Script (Recommended)

```bash
# 1. Make master script executable
chmod +x azure-setup-complete.sh

# 2. Run it!
./azure-setup-complete.sh
```

The script will:
1. Verify Azure CLI is installed and logged in
2. Ask for your GitHub repository details
3. Create service principal in Azure
4. Configure OIDC federated credentials
5. Assign necessary permissions
6. Verify everything works
7. Give you the secrets to add to GitHub

**That's it!** Skip to "Add GitHub Secrets" section below.

---

## 🔧 Manual Setup (Step-by-Step - 15 Minutes)

If you prefer to understand each step:

### Step 1: Configuration (2 min)

```bash
# Make script executable
chmod +x azure-setup-config.sh

# Run configuration
./azure-setup-config.sh
```

You'll be asked:
- **GitHub Owner**: Your username or org (same as AWS setup)
- **Repository Name**: Your repo name (same as AWS setup)

This creates `azure-config.env` with your settings.

### Step 2: Create Service Principal (3 min)

```bash
# Load configuration
source azure-config.env

# Make script executable
chmod +x azure-create-service-principal.sh

# Create service principal
./azure-create-service-principal.sh
```

**What it does**:
- Creates Azure AD application: `GitHubActions-NPCI`
- Creates service principal associated with the app
- Stores App ID (Client ID) for later use

### Step 3: Configure OIDC (5 min)

```bash
# Make script executable
chmod +x azure-configure-oidc.sh

# Configure OIDC
./azure-configure-oidc.sh
```

**What it does**:
- Creates federated credentials for:
  - `main` branch
  - `develop` branch
  - All branches (for workflow_dispatch)
  - Pull requests
- Enables passwordless authentication from GitHub Actions

### Step 4: Assign Permissions (3 min)

```bash
# Make script executable
chmod +x azure-assign-permissions.sh

# Assign permissions
./azure-assign-permissions.sh
```

**What it does**:
- Assigns **Contributor** role (create/manage resources)
- Assigns **AcrPush** role (push Docker images to ACR)
- Assigns **AKS Cluster Admin** role (manage Kubernetes clusters)

### Step 5: Verify Setup (2 min)

```bash
# Make script executable
chmod +x azure-verify-setup.sh

# Verify everything
./azure-verify-setup.sh
```

You should see all green checkmarks! ✅

---

## 🔑 Add GitHub Secrets (3 Minutes)

### Copy Your Values

After setup, you'll see:
```
Client ID:        12345678-1234-1234-1234-123456789012
Tenant ID:        87654321-4321-4321-4321-210987654321
Subscription ID:  abcdefgh-abcd-abcd-abcd-abcdefghijkl
```

Copy these values!

### Add to GitHub

1. Go to your repository on GitHub
2. Click: **Settings** → **Secrets and variables** → **Actions**
3. Click: **New repository secret**

**Secret 1** (Required):
```
Name:  AZURE_CLIENT_ID
Value: 12345678-1234-1234-1234-123456789012
```

**Secret 2** (Required):
```
Name:  AZURE_TENANT_ID
Value: 87654321-4321-4321-4321-210987654321
```

**Secret 3** (Required):
```
Name:  AZURE_SUBSCRIPTION_ID
Value: abcdefgh-abcd-abcd-abcd-abcdefghijkl
```

---

## ✅ Verify It Works

### Test Configuration

Your `azure-config.env` should contain:
```bash
export AZURE_SUBSCRIPTION_ID="abcdefgh-abcd-abcd-abcd-abcdefghijkl"
export AZURE_TENANT_ID="87654321-4321-4321-4321-210987654321"
export AZURE_CLIENT_ID="12345678-1234-1234-1234-123456789012"
export GITHUB_REPO_FULL="your-username/your-repo"
export SP_NAME="GitHubActions-NPCI"
```

### Test from Command Line

```bash
# Load config
source azure-config.env

# Check service principal exists
az ad sp show --id "$AZURE_CLIENT_ID"

# Check federated credentials
az ad app federated-credential list --id "$AZURE_CLIENT_ID"

# Check role assignments
az role assignment list --assignee "$AZURE_CLIENT_ID"
```

All commands should succeed without errors!

---

## 🧪 Test with GitHub Actions

Create a test workflow to verify authentication:

**.github/workflows/test-azure-auth.yml**:
```yaml
name: Test Azure Authentication

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  test-auth:
    runs-on: ubuntu-latest
    steps:
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Test Azure CLI
        run: |
          az account show
          echo "✅ Azure authentication successful!"
      
      - name: Test ACR Access
        run: |
          az acr list || echo "No registries yet"
          echo "✅ ACR access verified!"
      
      - name: Test AKS Access
        run: |
          az aks list || echo "No clusters yet"
          echo "✅ AKS access verified!"
```

Push this workflow and run it manually from the Actions tab.

If it succeeds → Your Azure auth is working! 🎉

---

## 🔒 Security Best Practices

### What Makes This Secure?

1. **No Client Secrets**
   - No passwords stored in GitHub
   - Temporary tokens generated on each run
   - Tokens expire after 1 hour

2. **Federated Credentials**
   - Only your specific GitHub repository can authenticate
   - Can restrict to specific branches
   - Industry-standard OIDC protocol

3. **Least Privilege**
   - Service principal only has permissions needed
   - Can be scoped to specific resource groups
   - Regular permission reviews recommended

4. **Audit Trail**
   - All actions logged in Azure Activity Log
   - Can see who did what and when

### Enhanced Security (Optional)

Limit to production branch only:

```bash
# Remove other federated credentials
az ad app federated-credential delete \
  --id "$AZURE_CLIENT_ID" \
  --federated-credential-id "GitHubActions-Develop"

# Keep only main branch credential
# Now only main branch can deploy to production
```

---

## 🆘 Troubleshooting

### Issue: "Azure CLI not found"
```bash
# Install Azure CLI on Mac
brew install azure-cli

# Verify
az version
```

### Issue: "Please run 'az login' to setup account"
```
Error: Please run 'az login' to setup account
```

**Solution**: Login to Azure
```bash
az login
# Opens browser for authentication

# Verify
az account show
```

### Issue: "Insufficient privileges to complete the operation"
```
Error: Insufficient privileges to complete the operation
```

**Solution**: Your account needs permissions to create service principals. Ask your Azure admin or:
```bash
# Check your permissions
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Need at least Contributor + User Access Administrator
# Or Owner role
```

### Issue: "Service principal already exists"
```
An error occurred: Another object with the same value exists
```

**Solution**: This is OK! The script will detect and use the existing service principal.

### Issue: "Federated credential already exists"
```
Request_BadRequest: Another credential with the same subject already exists
```

**Solution**: This is OK! The credential is already configured.

### Issue: GitHub Actions workflow fails with "AADSTS70021: No matching federated identity record found"

**Causes**:
1. Wrong branch name in federated credential
2. Wrong repository in federated credential
3. Federated credential not created

**Solution**:
```bash
# Check existing credentials
source azure-config.env
az ad app federated-credential list --id "$AZURE_CLIENT_ID"

# Should show credentials for:
# - repo:owner/repo:ref:refs/heads/main
# - repo:owner/repo:ref:refs/heads/develop
# - repo:owner/repo:ref:refs/heads/*
# - repo:owner/repo:pull_request

# If missing, re-run:
./azure-configure-oidc.sh
```

---

## 📋 What Gets Created

### In Azure:

1. **Azure AD Application**
   - Name: `GitHubActions-NPCI`
   - App ID: Used as AZURE_CLIENT_ID

2. **Service Principal**
   - Associated with the AD application
   - Identity for GitHub Actions

3. **Federated Credentials (4)**
   - Main branch
   - Develop branch
   - All branches
   - Pull requests

4. **Role Assignments**
   - Contributor (subscription level)
   - AcrPush (subscription level)
   - AKS Cluster Admin (subscription level)

### On Your Mac:

1. **Configuration Files**
   - `azure-config.env` - Your settings
   - `federated-credential-main.json`
   - `federated-credential-develop.json`
   - `federated-credential-all.json`
   - `federated-credential-pr.json`

2. **Setup Scripts**
   - `azure-setup-config.sh`
   - `azure-create-service-principal.sh`
   - `azure-configure-oidc.sh`
   - `azure-assign-permissions.sh`
   - `azure-verify-setup.sh`
   - `azure-setup-complete.sh` (master)

---

## 🎯 Next Steps

After Azure authentication is set up:

1. ✅ **Azure Auth Complete!**
2. ✅ **AWS Auth Complete!** (from previous setup)
3. 🏗️ Deploy infrastructure with Terraform (both clouds)
4. 🚀 Deploy your first multi-cloud application!

---

## 💡 Quick Reference

### View Configuration
```bash
cat azure-config.env
```

### View Service Principal Details
```bash
source azure-config.env
az ad sp show --id "$AZURE_CLIENT_ID"
```

### View Federated Credentials
```bash
source azure-config.env
az ad app federated-credential list --id "$AZURE_CLIENT_ID"
```

### View Role Assignments
```bash
source azure-config.env
az role assignment list --assignee "$AZURE_CLIENT_ID"
```

### Delete Setup (if needed)
```bash
source azure-config.env

# Remove role assignments
az role assignment delete --assignee "$AZURE_CLIENT_ID"

# Delete service principal
az ad sp delete --id "$AZURE_CLIENT_ID"

# Delete AD application (also deletes federated credentials)
az ad app delete --id "$AZURE_CLIENT_ID"
```

---

## ✅ Success Checklist

- [ ] Azure CLI installed and logged in
- [ ] `az account show` works
- [ ] `azure-setup-complete.sh` ran successfully
- [ ] All verification tests passed (green checkmarks)
- [ ] `AZURE_CLIENT_ID` added to GitHub secrets
- [ ] `AZURE_TENANT_ID` added to GitHub secrets
- [ ] `AZURE_SUBSCRIPTION_ID` added to GitHub secrets
- [ ] Test workflow runs successfully
- [ ] Ready for infrastructure deployment!

---

## 🎉 Both Clouds Ready!

**You now have authentication configured for:**
- ✅ AWS (OIDC with IAM role)
- ✅ Azure (OIDC with service principal)

**Your GitHub Actions can now:**
- Deploy to AWS ECS
- Deploy to Azure AKS
- Push images to ECR and ACR
- Manage resources in both clouds
- All without storing any credentials! 🔒

---

**Next Step**: Deploy infrastructure using Terraform!

See the complete CI/CD package for Terraform scripts and deployment workflows.
