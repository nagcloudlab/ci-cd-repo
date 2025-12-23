#!/bin/bash
# AWS OIDC Setup - Master Script
# This script runs all setup steps in sequence

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear

echo "================================================"
echo "   AWS OIDC Setup for GitHub Actions"
echo "   Complete Automated Setup"
echo "================================================"
echo ""
echo "This script will:"
echo "  1. Collect your configuration"
echo "  2. Create OIDC provider in AWS"
echo "  3. Create IAM role with proper permissions"
echo "  4. Verify the setup"
echo ""
echo "Prerequisites:"
echo "  ✓ AWS CLI installed and configured"
echo "  ✓ Proper AWS permissions (IAM admin)"
echo "  ✓ GitHub repository created"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Make scripts executable
chmod +x aws-setup-config.sh
chmod +x aws-create-oidc-provider.sh
chmod +x aws-create-iam-role.sh
chmod +x aws-verify-setup.sh

# Step 1: Configuration
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 1: Configuration${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./aws-setup-config.sh

if [ ! -f aws-config.env ]; then
    echo -e "${RED}❌ Configuration failed${NC}"
    exit 1
fi

source aws-config.env
echo ""
echo -e "${GREEN}✅ Configuration complete${NC}"
echo ""
read -p "Press Enter to continue to Step 2..."
echo ""

# Step 2: Create OIDC Provider
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 2: Create OIDC Provider${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./aws-create-oidc-provider.sh

echo ""
read -p "Press Enter to continue to Step 3..."
echo ""

# Step 3: Create IAM Role
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 3: Create IAM Role${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./aws-create-iam-role.sh

echo ""
read -p "Press Enter to continue to Step 4 (Verification)..."
echo ""

# Step 4: Verify Setup
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 4: Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./aws-verify-setup.sh

# Final Summary
echo ""
echo "================================================"
echo -e "${GREEN}   🎉 AWS Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Configuration saved in: aws-config.env"
echo ""
echo -e "${YELLOW}📋 Copy this to GitHub Secrets:${NC}"
echo ""
echo "Secret Name:  AWS_ROLE_ARN"
echo "Secret Value: $IAM_ROLE_ARN"
echo ""
echo "Secret Name:  AWS_REGION (optional)"
echo "Secret Value: $AWS_REGION"
echo ""
echo -e "${YELLOW}How to add GitHub Secrets:${NC}"
echo "1. Go to: https://github.com/$GITHUB_REPO_FULL/settings/secrets/actions"
echo "2. Click: 'New repository secret'"
echo "3. Add the secrets above"
echo ""
echo "Your workflows can now deploy to AWS! 🚀"
echo ""
