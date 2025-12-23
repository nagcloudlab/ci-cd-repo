#!/bin/bash
# Azure OIDC Setup - Master Script
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
echo "   Azure OIDC Setup for GitHub Actions"
echo "   Complete Automated Setup"
echo "================================================"
echo ""
echo "This script will:"
echo "  1. Collect your configuration"
echo "  2. Create service principal in Azure"
echo "  3. Configure OIDC federated credentials"
echo "  4. Assign necessary permissions"
echo "  5. Verify the setup"
echo ""
echo "Prerequisites:"
echo "  ✓ Azure CLI installed and configured"
echo "  ✓ Logged in to Azure (az login)"
echo "  ✓ Contributor permissions on subscription"
echo "  ✓ GitHub repository created"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Make scripts executable
chmod +x azure-setup-config.sh
chmod +x azure-create-service-principal.sh
chmod +x azure-configure-oidc.sh
chmod +x azure-assign-permissions.sh
chmod +x azure-verify-setup.sh

# Step 1: Configuration
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 1: Configuration${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./azure-setup-config.sh

if [ ! -f azure-config.env ]; then
    echo -e "${RED}❌ Configuration failed${NC}"
    exit 1
fi

source azure-config.env
echo ""
echo -e "${GREEN}✅ Configuration complete${NC}"
echo ""
read -p "Press Enter to continue to Step 2..."
echo ""

# Step 2: Create Service Principal
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 2: Create Service Principal${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./azure-create-service-principal.sh

# Reload config to get new values
source azure-config.env

echo ""
read -p "Press Enter to continue to Step 3..."
echo ""

# Step 3: Configure OIDC
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 3: Configure OIDC Federated Credentials${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./azure-configure-oidc.sh

echo ""
read -p "Press Enter to continue to Step 4..."
echo ""

# Step 4: Assign Permissions
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 4: Assign Permissions${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./azure-assign-permissions.sh

echo ""
read -p "Press Enter to continue to Step 5 (Verification)..."
echo ""

# Step 5: Verify Setup
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Step 5: Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
./azure-verify-setup.sh

# Final Summary
echo ""
echo "================================================"
echo -e "${GREEN}   🎉 Azure Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Configuration saved in: azure-config.env"
echo ""
echo -e "${YELLOW}📋 Copy these to GitHub Secrets:${NC}"
echo ""
echo "Secret Name:  AZURE_CLIENT_ID"
echo "Secret Value: $AZURE_CLIENT_ID"
echo ""
echo "Secret Name:  AZURE_TENANT_ID"
echo "Secret Value: $AZURE_TENANT_ID"
echo ""
echo "Secret Name:  AZURE_SUBSCRIPTION_ID"
echo "Secret Value: $AZURE_SUBSCRIPTION_ID"
echo ""
echo -e "${YELLOW}How to add GitHub Secrets:${NC}"
echo "1. Go to: https://github.com/$GITHUB_REPO_FULL/settings/secrets/actions"
echo "2. Click: 'New repository secret'"
echo "3. Add the three secrets above"
echo ""
echo -e "${GREEN}Your workflows can now deploy to Azure! 🚀${NC}"
echo ""
echo -e "${BLUE}Combined with AWS setup, you can now deploy to BOTH clouds!${NC}"
echo ""
