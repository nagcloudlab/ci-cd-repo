#!/bin/bash
# Verify AWS OIDC Setup
# This script tests that everything is configured correctly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "   Verifying AWS OIDC Setup"
echo "================================================"
echo ""

# Load configuration
if [ ! -f aws-config.env ]; then
    echo -e "${RED}❌ Error: aws-config.env not found${NC}"
    exit 1
fi

source aws-config.env

ERRORS=0

# Test 1: Check OIDC Provider
echo -e "${BLUE}Test 1: OIDC Provider${NC}"
if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ OIDC provider exists${NC}"
    echo "   ARN: $OIDC_PROVIDER_ARN"
else
    echo -e "${RED}❌ OIDC provider not found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 2: Check IAM Role
echo -e "${BLUE}Test 2: IAM Role${NC}"
if aws iam get-role --role-name "$IAM_ROLE_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ IAM role exists${NC}"
    echo "   Role: $IAM_ROLE_NAME"
    echo "   ARN: $IAM_ROLE_ARN"
else
    echo -e "${RED}❌ IAM role not found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 3: Check Trust Policy
echo -e "${BLUE}Test 3: Trust Policy${NC}"
TRUST_POLICY=$(aws iam get-role --role-name "$IAM_ROLE_NAME" --query 'Role.AssumeRolePolicyDocument' 2>/dev/null)
if echo "$TRUST_POLICY" | grep -q "$GITHUB_REPO_FULL"; then
    echo -e "${GREEN}✅ Trust policy configured correctly${NC}"
    echo "   Allows: repo:$GITHUB_REPO_FULL:*"
else
    echo -e "${RED}❌ Trust policy not configured correctly${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 4: Check Attached Policies
echo -e "${BLUE}Test 4: Attached Policies${NC}"
POLICIES=$(aws iam list-attached-role-policies --role-name "$IAM_ROLE_NAME" --query 'AttachedPolicies[].PolicyName' --output text)
if echo "$POLICIES" | grep -q "AmazonEC2ContainerRegistryPowerUser"; then
    echo -e "${GREEN}✅ ECR policy attached${NC}"
else
    echo -e "${RED}❌ ECR policy missing${NC}"
    ERRORS=$((ERRORS + 1))
fi

if echo "$POLICIES" | grep -q "AmazonECS_FullAccess"; then
    echo -e "${GREEN}✅ ECS policy attached${NC}"
else
    echo -e "${RED}❌ ECS policy missing${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 5: Check Inline Policy
echo -e "${BLUE}Test 5: Inline Policy${NC}"
if aws iam get-role-policy --role-name "$IAM_ROLE_NAME" --policy-name "GitHubActionsAdditionalPermissions" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Inline policy exists${NC}"
else
    echo -e "${YELLOW}⚠️  Inline policy not found (optional)${NC}"
fi
echo ""

# Summary
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}   ✅ All Tests Passed!${NC}"
    echo "================================================"
    echo ""
    echo "Your AWS OIDC setup is complete and verified!"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Add this secret to GitHub:"
    echo "   Repository → Settings → Secrets → Actions → New secret"
    echo ""
    echo "   Name:  AWS_ROLE_ARN"
    echo "   Value: $IAM_ROLE_ARN"
    echo ""
    echo "2. Optionally add:"
    echo "   Name:  AWS_REGION"
    echo "   Value: $AWS_REGION"
    echo ""
    echo "3. Your workflows can now authenticate to AWS using OIDC!"
    echo ""
else
    echo -e "${RED}   ❌ $ERRORS Test(s) Failed${NC}"
    echo "================================================"
    echo ""
    echo "Please review the errors above and run the appropriate setup scripts."
fi
echo ""
