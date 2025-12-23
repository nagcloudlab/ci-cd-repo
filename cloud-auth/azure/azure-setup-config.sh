#!/bin/bash
# Azure OIDC Setup Configuration
# Run this script to collect necessary information

set -e

echo "================================================"
echo "   Azure OIDC Setup for GitHub Actions"
echo "================================================"
echo ""

# Check Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found!"
    echo ""
    echo "Install it with:"
    echo "  brew install azure-cli"
    echo ""
    exit 1
fi

echo "✅ Azure CLI found: $(az version --query '"azure-cli"' -o tsv)"
echo ""

# Check if logged in
echo "📊 Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "⚠️  Not logged in to Azure"
    echo ""
    echo "Please login first:"
    echo "  az login"
    echo ""
    exit 1
fi

# Get Azure subscription info
echo "✅ Logged in to Azure"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
echo ""
echo "Subscription: $SUBSCRIPTION_NAME"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Tenant ID: $TENANT_ID"
echo ""

# Get GitHub repository information
echo "🐙 GitHub Repository Information"
echo "Enter your GitHub username or organization:"
read -p "GitHub Owner: " GITHUB_OWNER
echo ""

echo "Enter your repository name (e.g., npci-transfer-service):"
read -p "Repository Name: " GITHUB_REPO
echo ""

# Service Principal name
SP_NAME="GitHubActions-NPCI"
echo "Service Principal will be named: $SP_NAME"
echo ""

# Confirm information
echo "================================================"
echo "   Configuration Summary"
echo "================================================"
echo "Azure Subscription:   $SUBSCRIPTION_NAME"
echo "Subscription ID:      $SUBSCRIPTION_ID"
echo "Tenant ID:            $TENANT_ID"
echo "GitHub Owner:         $GITHUB_OWNER"
echo "GitHub Repository:    $GITHUB_REPO"
echo "Full Repo Path:       $GITHUB_OWNER/$GITHUB_REPO"
echo "Service Principal:    $SP_NAME"
echo "================================================"
echo ""

read -p "Is this information correct? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Setup cancelled. Please run the script again."
    exit 1
fi

# Save configuration
cat > azure-config.env << EOF
# Azure OIDC Configuration
# Generated on $(date)

export AZURE_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export AZURE_SUBSCRIPTION_NAME="$SUBSCRIPTION_NAME"
export AZURE_TENANT_ID="$TENANT_ID"
export GITHUB_OWNER="$GITHUB_OWNER"
export GITHUB_REPO="$GITHUB_REPO"
export GITHUB_REPO_FULL="$GITHUB_OWNER/$GITHUB_REPO"
export SP_NAME="$SP_NAME"
export AZURE_REGION="centralindia"
EOF

echo ""
echo "✅ Configuration saved to: azure-config.env"
echo ""
echo "Next steps:"
echo "1. Run: source azure-config.env"
echo "2. Run: ./azure-create-service-principal.sh"
echo ""
