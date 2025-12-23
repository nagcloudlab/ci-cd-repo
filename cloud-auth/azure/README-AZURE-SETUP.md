# Azure Authentication Setup Scripts

**Quick setup for GitHub Actions OIDC authentication with Azure**

---

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Login to Azure
az login

# 2. Make scripts executable
chmod +x *.sh

# 3. Run master setup script
./azure-setup-complete.sh

# 4. Follow the prompts!
```

That's it! The script will guide you through everything.

---

## 📦 What's Included

### Scripts (Use these)
- **`azure-setup-complete.sh`** ⭐ - Master script (run this!)
- `azure-setup-config.sh` - Collect configuration
- `azure-create-service-principal.sh` - Create service principal
- `azure-configure-oidc.sh` - Configure federated credentials
- `azure-assign-permissions.sh` - Assign permissions
- `azure-verify-setup.sh` - Verify everything works

### Documentation
- **`AZURE-SETUP-GUIDE.md`** - Complete step-by-step guide

### Generated Files (after running setup)
- `azure-config.env` - Your configuration
- `federated-credential-*.json` - OIDC credentials

---

## 📋 Prerequisites

- ✅ Mac with Azure CLI installed (`az version`)
- ✅ Azure subscription with Contributor access
- ✅ GitHub repository created
- ✅ Logged in to Azure (`az login`)
- ✅ 5 minutes of your time

---

## 🎯 What You'll Get

After running the setup:

1. **Service Principal** in Azure AD
2. **Federated Credentials** for OIDC (4 credentials)
3. **Proper Permissions** for AKS/ACR deployment
4. **Three IDs** to add to GitHub Secrets
5. **Verified Configuration** (all tests pass)

---

## 🔑 GitHub Secrets

After setup, add to GitHub:

**Repository → Settings → Secrets → Actions → New secret**

```
Name:  AZURE_CLIENT_ID
Value: 12345678-1234-1234-1234-123456789012
       (copy from script output)

Name:  AZURE_TENANT_ID
Value: 87654321-4321-4321-4321-210987654321
       (copy from script output)

Name:  AZURE_SUBSCRIPTION_ID
Value: abcdefgh-abcd-abcd-abcd-abcdefghijkl
       (copy from script output)
```

---

## 📚 Documentation

- **Quick Setup**: Run `./azure-setup-complete.sh`
- **Detailed Guide**: Read `AZURE-SETUP-GUIDE.md`
- **Manual Steps**: Follow guide for step-by-step
- **Troubleshooting**: See guide for common issues

---

## ✅ Verification

The setup script automatically verifies:
- ✅ Azure CLI logged in
- ✅ Service principal created
- ✅ Federated credentials configured (4 credentials)
- ✅ Permissions assigned (3 roles)
- ✅ Configuration complete
- ✅ Ready for GitHub Actions

---

## 🆘 Need Help?

### Quick Checks

```bash
# Load configuration
source azure-config.env

# Check service principal
az ad sp show --id "$AZURE_CLIENT_ID"

# Check federated credentials
az ad app federated-credential list --id "$AZURE_CLIENT_ID"

# Check permissions
az role assignment list --assignee "$AZURE_CLIENT_ID"
```

### Common Issues

**"Azure CLI not found"**
```bash
brew install azure-cli
```

**"Please run 'az login'"**
```bash
az login
```

**"Insufficient privileges"**
- Need Contributor + ability to create service principals
- Ask your Azure administrator

**See `AZURE-SETUP-GUIDE.md` for complete troubleshooting!**

---

## 🔄 Re-run Setup

Safe to run multiple times:
- Scripts detect existing resources
- Updates configurations
- Won't create duplicates

---

## 🎉 Success!

When you see all green checkmarks ✅:

1. Copy the three IDs (Client, Tenant, Subscription)
2. Add all three to GitHub Secrets
3. Test with a workflow
4. Combined with AWS, you can deploy to BOTH clouds! 🚀

---

## 🌐 Multi-Cloud Ready

**After completing both setups:**
- ✅ AWS authentication configured
- ✅ Azure authentication configured
- ✅ Ready for multi-cloud deployment
- ✅ No credentials stored in GitHub
- ✅ Production-ready security

**Next Step**: Deploy infrastructure with Terraform!
