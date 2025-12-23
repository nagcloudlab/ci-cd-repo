#!/bin/bash
# Verify Azure OIDC Setup
# This script tests that everything is configured correctly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "   Verifying Azure OIDC Setup"
echo "================================================"
echo ""

# Load configuration
if [ ! -f azure-config.env ]; then
    echo -e "${RED}❌ Error: azure-config.env not found${NC}"
    exit 1
fi

source azure-config.env

ERRORS=0

# Test 1: Check Azure CLI login
echo -e "${BLUE}Test 1: Azure CLI Login${NC}"
if az account show >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Logged in to Azure${NC}"
    CURRENT_SUB=$(az account show --query name -o tsv)
    echo "   Subscription: $CURRENT_SUB"
else
    echo -e "${RED}❌ Not logged in to Azure${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 2: Check Service Principal exists
echo -e "${BLUE}Test 2: Service Principal${NC}"
if az ad sp show --id "$AZURE_CLIENT_ID" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Service principal exists${NC}"
    echo "   App ID: $AZURE_CLIENT_ID"
    SP_NAME_CHECK=$(az ad sp show --id "$AZURE_CLIENT_ID" --query displayName -o tsv)
    echo "   Name: $SP_NAME_CHECK"
else
    echo -e "${RED}❌ Service principal not found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 3: Check Federated Credentials
echo -e "${BLUE}Test 3: Federated Credentials${NC}"
CRED_COUNT=$(az ad app federated-credential list --id "$AZURE_CLIENT_ID" --query "length(@)" -o tsv 2>/dev/null || echo "0")

if [ "$CRED_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Federated credentials configured${NC}"
    echo "   Count: $CRED_COUNT"
    
    # List credentials
    az ad app federated-credential list --id "$AZURE_CLIENT_ID" \
        --query "[].{Name:name, Subject:subject}" \
        --output table 2>/dev/null | grep -v "^-" | grep -v "^Name"
else
    echo -e "${RED}❌ No federated credentials found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 4: Check Role Assignments
echo -e "${BLUE}Test 4: Role Assignments${NC}"
ROLE_COUNT=$(az role assignment list --assignee "$AZURE_SP_OBJECT_ID" --query "length(@)" -o tsv 2>/dev/null || echo "0")

if [ "$ROLE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Roles assigned${NC}"
    echo "   Count: $ROLE_COUNT"
    
    # Check for Contributor role
    if az role assignment list --assignee "$AZURE_SP_OBJECT_ID" --query "[?roleDefinitionName=='Contributor']" -o tsv | grep -q "Contributor"; then
        echo "   ✅ Contributor role found"
    else
        echo -e "${YELLOW}   ⚠️  Contributor role not found${NC}"
    fi
    
    # Check for AcrPush role
    if az role assignment list --assignee "$AZURE_SP_OBJECT_ID" --query "[?roleDefinitionName=='AcrPush']" -o tsv | grep -q "AcrPush"; then
        echo "   ✅ AcrPush role found"
    else
        echo -e "${YELLOW}   ⚠️  AcrPush role not found${NC}"
    fi
else
    echo -e "${RED}❌ No role assignments found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 5: Check Configuration File
echo -e "${BLUE}Test 5: Configuration File${NC}"
if [ -n "$AZURE_CLIENT_ID" ] && [ -n "$AZURE_TENANT_ID" ] && [ -n "$AZURE_SUBSCRIPTION_ID" ]; then
    echo -e "${GREEN}✅ Configuration complete${NC}"
    echo "   Client ID: $AZURE_CLIENT_ID"
    echo "   Tenant ID: $AZURE_TENANT_ID"
    echo "   Subscription: $AZURE_SUBSCRIPTION_ID"
else
    echo -e "${RED}❌ Configuration incomplete${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}   ✅ All Tests Passed!${NC}"
    echo "================================================"
    echo ""
    echo "Your Azure OIDC setup is complete and verified!"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Add these secrets to GitHub:"
    echo "   Repository → Settings → Secrets → Actions → New secret"
    echo ""
    echo "   Name:  AZURE_CLIENT_ID"
    echo "   Value: $AZURE_CLIENT_ID"
    echo ""
    echo "   Name:  AZURE_TENANT_ID"
    echo "   Value: $AZURE_TENANT_ID"
    echo ""
    echo "   Name:  AZURE_SUBSCRIPTION_ID"
    echo "   Value: $AZURE_SUBSCRIPTION_ID"
    echo ""
    echo "2. Your workflows can now authenticate to Azure using OIDC!"
    echo ""
    echo "3. Combined with AWS setup, you can now deploy to both clouds!"
    echo ""
else
    echo -e "${RED}   ❌ $ERRORS Test(s) Failed${NC}"
    echo "================================================"
    echo ""
    echo "Please review the errors above and run the appropriate setup scripts."
fi
echo ""
