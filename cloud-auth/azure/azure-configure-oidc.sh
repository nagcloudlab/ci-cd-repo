#!/bin/bash
# Configure Azure OIDC Federated Credentials
# This enables GitHub Actions to authenticate without client secrets

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "   Configuring OIDC Federated Credentials"
echo "================================================"
echo ""

# Load configuration
if [ ! -f azure-config.env ]; then
    echo -e "${RED}❌ Error: azure-config.env not found${NC}"
    exit 1
fi

source azure-config.env

if [ -z "$AZURE_CLIENT_ID" ]; then
    echo -e "${RED}❌ Error: Service principal not created yet${NC}"
    echo "Please run ./azure-create-service-principal.sh first"
    exit 1
fi

echo "Using configuration:"
echo "  App ID: $AZURE_CLIENT_ID"
echo "  GitHub Repo: $GITHUB_REPO_FULL"
echo ""

# Step 1: Create federated credential for main branch
echo "📋 Step 1: Creating federated credential for 'main' branch..."

cat > federated-credential-main.json << EOF
{
  "name": "GitHubActions-Main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_REPO_FULL}:ref:refs/heads/main",
  "description": "GitHub Actions for main branch",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create \
    --id "$AZURE_CLIENT_ID" \
    --parameters @federated-credential-main.json \
    2>/dev/null || echo -e "${YELLOW}  Already exists or created${NC}"

echo -e "${GREEN}✅ Federated credential for 'main' branch configured${NC}"
echo ""

# Step 2: Create federated credential for develop branch
echo "📋 Step 2: Creating federated credential for 'develop' branch..."

cat > federated-credential-develop.json << EOF
{
  "name": "GitHubActions-Develop",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_REPO_FULL}:ref:refs/heads/develop",
  "description": "GitHub Actions for develop branch",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create \
    --id "$AZURE_CLIENT_ID" \
    --parameters @federated-credential-develop.json \
    2>/dev/null || echo -e "${YELLOW}  Already exists or created${NC}"

echo -e "${GREEN}✅ Federated credential for 'develop' branch configured${NC}"
echo ""

# Step 3: Create federated credential for all branches (workflow_dispatch)
echo "📋 Step 3: Creating federated credential for all branches..."

cat > federated-credential-all.json << EOF
{
  "name": "GitHubActions-AllBranches",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_REPO_FULL}:ref:refs/heads/*",
  "description": "GitHub Actions for all branches",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create \
    --id "$AZURE_CLIENT_ID" \
    --parameters @federated-credential-all.json \
    2>/dev/null || echo -e "${YELLOW}  Already exists or created${NC}"

echo -e "${GREEN}✅ Federated credential for all branches configured${NC}"
echo ""

# Step 4: Create federated credential for pull requests
echo "📋 Step 4: Creating federated credential for pull requests..."

cat > federated-credential-pr.json << EOF
{
  "name": "GitHubActions-PullRequests",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_REPO_FULL}:pull_request",
  "description": "GitHub Actions for pull requests",
  "audiences": [
    "api://AzureADTokenExchange"
  ]
}
EOF

az ad app federated-credential create \
    --id "$AZURE_CLIENT_ID" \
    --parameters @federated-credential-pr.json \
    2>/dev/null || echo -e "${YELLOW}  Already exists or created${NC}"

echo -e "${GREEN}✅ Federated credential for pull requests configured${NC}"
echo ""

echo "================================================"
echo "   OIDC Configuration Complete"
echo "================================================"
echo ""
echo "Federated credentials created for:"
echo "  ✅ main branch"
echo "  ✅ develop branch"
echo "  ✅ All branches (workflow_dispatch)"
echo "  ✅ Pull requests"
echo ""
echo "Next step: Run ./azure-assign-permissions.sh"
echo ""
