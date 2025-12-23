# AWS Authentication Setup Scripts

**Quick setup for GitHub Actions OIDC authentication with AWS**

---

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Make scripts executable
chmod +x *.sh

# 2. Run master setup script
./aws-setup-complete.sh

# 3. Follow the prompts!
```

That's it! The script will guide you through everything.

---

## 📦 What's Included

### Scripts (Use these)
- **`aws-setup-complete.sh`** ⭐ - Master script (run this!)
- `aws-setup-config.sh` - Collect configuration
- `aws-create-oidc-provider.sh` - Create OIDC provider
- `aws-create-iam-role.sh` - Create IAM role
- `aws-verify-setup.sh` - Verify everything works

### Documentation
- **`AWS-SETUP-GUIDE.md`** - Complete step-by-step guide

### Generated Files (after running setup)
- `aws-config.env` - Your configuration
- `trust-policy.json` - IAM trust policy
- `inline-policy.json` - Additional permissions

---

## 📋 Prerequisites

- ✅ Mac with AWS CLI installed (`aws --version`)
- ✅ AWS account with IAM permissions
- ✅ GitHub repository created
- ✅ 5 minutes of your time

---

## 🎯 What You'll Get

After running the setup:

1. **OIDC Provider** in AWS
2. **IAM Role** for GitHub Actions
3. **Proper Permissions** for ECS/ECR deployment
4. **Role ARN** to add to GitHub Secrets
5. **Verified Configuration** (all tests pass)

---

## 🔑 GitHub Secrets

After setup, add to GitHub:

**Repository → Settings → Secrets → Actions → New secret**

```
Name:  AWS_ROLE_ARN
Value: arn:aws:iam::123456789012:role/GitHubActions-NPCI-Role
       (copy from script output)
```

---

## 📚 Documentation

- **Quick Setup**: Run `./aws-setup-complete.sh`
- **Detailed Guide**: Read `AWS-SETUP-GUIDE.md`
- **Manual Steps**: Follow guide for step-by-step
- **Troubleshooting**: See guide for common issues

---

## ✅ Verification

The setup script automatically verifies:
- ✅ OIDC provider created
- ✅ IAM role created
- ✅ Trust policy configured
- ✅ Policies attached
- ✅ Ready for GitHub Actions

---

## 🆘 Need Help?

### Quick Checks

```bash
# Load configuration
source aws-config.env

# Check OIDC provider
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN"

# Check IAM role
aws iam get-role --role-name "$IAM_ROLE_NAME"
```

### Common Issues

**"AWS CLI not found"**
```bash
brew install awscli
```

**"Access Denied"**
- Need IAM admin permissions
- Ask your AWS administrator

**See `AWS-SETUP-GUIDE.md` for complete troubleshooting!**

---

## 🔄 Re-run Setup

Safe to run multiple times:
- Scripts detect existing resources
- Updates configurations
- Won't create duplicates

---

## 🎉 Success!

When you see all green checkmarks ✅:

1. Copy the Role ARN
2. Add to GitHub Secrets
3. Test with a workflow
4. You're ready to deploy! 🚀

---

**Next Step**: Set up Azure authentication
