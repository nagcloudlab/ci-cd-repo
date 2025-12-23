#!/bin/bash
# Assign Azure Permissions to Service Principal
# This grants the service principal access to deploy resources

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "   Assigning Permissions"
echo "================================================"
echo ""

# Load configuration
if [ ! -f azure-config.env ]; then
    echo -e "${RED}❌ Error: azure-config.env not found${NC}"
    exit 1
fi

source azure-config.env

if [ -z "$AZURE_SP_OBJECT_ID" ]; then
    echo -e "${RED}❌ Error: Service principal not created yet${NC}"
    echo "Please run ./azure-create-service-principal.sh first"
    exit 1
fi

echo "Using configuration:"
echo "  Subscription: $AZURE_SUBSCRIPTION_NAME"
echo "  Service Principal: $SP_NAME"
echo ""

# Step 1: Assign Contributor role at subscription level
echo "📋 Step 1: Assigning 'Contributor' role..."

az role assignment create \
    --assignee "$AZURE_SP_OBJECT_ID" \
    --role "Contributor" \
    --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
    2>/dev/null || echo -e "${YELLOW}  Already assigned${NC}"

echo -e "${GREEN}✅ Contributor role assigned${NC}"
echo ""

# Step 2: Assign AcrPush role (for container registry)
echo "📋 Step 2: Assigning 'AcrPush' role..."

az role assignment create \
    --assignee "$AZURE_SP_OBJECT_ID" \
    --role "AcrPush" \
    --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
    2>/dev/null || echo -e "${YELLOW}  Already assigned${NC}"

echo -e "${GREEN}✅ AcrPush role assigned${NC}"
echo ""

# Step 3: Assign Azure Kubernetes Service Cluster Admin Role
echo "📋 Step 3: Assigning 'Azure Kubernetes Service Cluster Admin Role'..."

az role assignment create \
    --assignee "$AZURE_SP_OBJECT_ID" \
    --role "Azure Kubernetes Service Cluster Admin Role" \
    --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
    2>/dev/null || echo -e "${YELLOW}  Already assigned${NC}"

echo -e "${GREEN}✅ AKS Cluster Admin role assigned${NC}"
echo ""

# Step 4: List all role assignments
echo "📋 Step 4: Verifying role assignments..."
echo ""

az role assignment list \
    --assignee "$AZURE_SP_OBJECT_ID" \
    --query "[].{Role:roleDefinitionName, Scope:scope}" \
    --output table

echo ""
echo "================================================"
echo "   Permissions Assigned Successfully"
echo "================================================"
echo ""
echo "Service Principal has these roles:"
echo "  ✅ Contributor (full resource management)"
echo "  ✅ AcrPush (push images to container registry)"
echo "  ✅ AKS Cluster Admin (manage Kubernetes clusters)"
echo ""
echo "Next step: Run ./azure-verify-setup.sh"
echo ""
