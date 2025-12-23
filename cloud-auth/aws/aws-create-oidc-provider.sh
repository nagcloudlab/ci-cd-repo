#!/bin/bash
# Create AWS OIDC Provider for GitHub Actions
# This script sets up the OIDC provider in your AWS account

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "   Creating AWS OIDC Provider"
echo "================================================"
echo ""

# Check if config exists
if [ ! -f aws-config.env ]; then
    echo -e "${RED}❌ Error: aws-config.env not found${NC}"
    echo "Please run ./aws-setup-config.sh first"
    exit 1
fi

# Load configuration
source aws-config.env

echo "Using configuration:"
echo "  AWS Account: $AWS_ACCOUNT_ID"
echo "  Region: $AWS_REGION"
echo "  GitHub Repo: $GITHUB_REPO_FULL"
echo ""

# Step 1: Check if OIDC provider already exists
echo "📋 Step 1: Checking if OIDC provider exists..."
PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER_URL}"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$PROVIDER_ARN" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  OIDC provider already exists${NC}"
    echo "Provider ARN: $PROVIDER_ARN"
else
    echo "Creating OIDC provider..."
    
    # Get GitHub's OIDC thumbprint
    THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"
    
    aws iam create-open-id-connect-provider \
        --url "https://${OIDC_PROVIDER_URL}" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "$THUMBPRINT" \
        --tags Key=Purpose,Value=GitHubActions Key=ManagedBy,Value=Terraform
    
    echo -e "${GREEN}✅ OIDC provider created successfully${NC}"
fi

echo ""
echo "================================================"
echo "   OIDC Provider Setup Complete"
echo "================================================"
echo ""
echo "Provider ARN: $PROVIDER_ARN"
echo ""
echo "Next step: Run ./aws-create-iam-role.sh"
echo ""

# Save provider ARN to config
echo "export OIDC_PROVIDER_ARN=\"$PROVIDER_ARN\"" >> aws-config.env
