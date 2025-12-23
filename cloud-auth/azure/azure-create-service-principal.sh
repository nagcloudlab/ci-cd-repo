#!/bin/bash
# Create Azure Service Principal for GitHub Actions
# This script creates the service principal with OIDC authentication

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "   Creating Azure Service Principal"
echo "================================================"
echo ""

# Load configuration
if [ ! -f azure-config.env ]; then
    echo -e "${RED}❌ Error: azure-config.env not found${NC}"
    echo "Please run ./azure-setup-config.sh first"
    exit 1
fi

source azure-config.env

echo "Using configuration:"
echo "  Subscription: $AZURE_SUBSCRIPTION_NAME"
echo "  Service Principal: $SP_NAME"
echo "  GitHub Repo: $GITHUB_REPO_FULL"
echo ""

# Step 1: Check if service principal already exists
echo "📋 Step 1: Checking if service principal exists..."

# Search for existing app
APP_ID=$(az ad app list --display-name "$SP_NAME" --query "[0].appId" -o tsv 2>/dev/null || echo "")

if [ -n "$APP_ID" ]; then
    echo -e "${YELLOW}⚠️  Service principal already exists${NC}"
    echo "App ID: $APP_ID"
    
    # Get object ID
    OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)
    
    echo "Using existing service principal"
else
    echo "Creating new service principal..."
    
    # Create Azure AD application
    az ad app create \
        --display-name "$SP_NAME" \
        --sign-in-audience AzureADMyOrg
    
    # Get the app ID
    APP_ID=$(az ad app list --display-name "$SP_NAME" --query "[0].appId" -o tsv)
    OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)
    
    echo -e "${GREEN}✅ Azure AD application created${NC}"
    echo "App ID: $APP_ID"
    
    # Create service principal
    az ad sp create --id "$APP_ID"
    
    echo -e "${GREEN}✅ Service principal created${NC}"
fi

echo ""

# Get service principal object ID
SP_OBJECT_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].id" -o tsv)
CLIENT_ID="$APP_ID"

echo "================================================"
echo "   Service Principal Created"
echo "================================================"
echo "Application (Client) ID: $CLIENT_ID"
echo "Object ID:               $OBJECT_ID"
echo "SP Object ID:            $SP_OBJECT_ID"
echo ""

# Save to config
cat >> azure-config.env << EOF

# Service Principal Details (added by azure-create-service-principal.sh)
export AZURE_CLIENT_ID="$CLIENT_ID"
export AZURE_APP_OBJECT_ID="$OBJECT_ID"
export AZURE_SP_OBJECT_ID="$SP_OBJECT_ID"
EOF

echo "✅ Configuration updated"
echo ""
echo "Next step: Run ./azure-configure-oidc.sh"
echo ""
