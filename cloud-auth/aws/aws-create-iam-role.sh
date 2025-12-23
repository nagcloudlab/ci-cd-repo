#!/bin/bash
# Create IAM Role for GitHub Actions with OIDC
# This script creates the IAM role that GitHub Actions will assume

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "================================================"
echo "   Creating IAM Role for GitHub Actions"
echo "================================================"
echo ""

# Load configuration
if [ ! -f aws-config.env ]; then
    echo -e "${RED}❌ Error: aws-config.env not found${NC}"
    exit 1
fi

source aws-config.env

echo "Using configuration:"
echo "  Role Name: $IAM_ROLE_NAME"
echo "  GitHub Repo: $GITHUB_REPO_FULL"
echo ""

# Step 1: Create trust policy
echo "📋 Step 1: Creating trust policy..."

cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER_URL}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO_FULL}:*"
        }
      }
    }
  ]
}
EOF

echo -e "${GREEN}✅ Trust policy created: trust-policy.json${NC}"
echo ""

# Step 2: Create IAM role
echo "📋 Step 2: Creating IAM role..."

if aws iam get-role --role-name "$IAM_ROLE_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Role already exists: $IAM_ROLE_NAME${NC}"
    echo "Updating trust policy..."
    
    aws iam update-assume-role-policy \
        --role-name "$IAM_ROLE_NAME" \
        --policy-document file://trust-policy.json
    
    echo -e "${GREEN}✅ Trust policy updated${NC}"
else
    echo "Creating new role..."
    
    aws iam create-role \
        --role-name "$IAM_ROLE_NAME" \
        --assume-role-policy-document file://trust-policy.json \
        --description "Role for GitHub Actions to deploy NPCI Transfer Service" \
        --tags Key=Purpose,Value=GitHubActions Key=Project,Value=NPCI-Transfer
    
    echo -e "${GREEN}✅ IAM role created successfully${NC}"
fi

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${IAM_ROLE_NAME}"
echo ""
echo "Role ARN: $ROLE_ARN"
echo ""

# Step 3: Attach policies
echo "📋 Step 3: Attaching policies to role..."

# List of policies to attach
POLICIES=(
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
)

for POLICY_ARN in "${POLICIES[@]}"; do
    POLICY_NAME=$(echo "$POLICY_ARN" | awk -F'/' '{print $NF}')
    echo "  Attaching: $POLICY_NAME..."
    
    aws iam attach-role-policy \
        --role-name "$IAM_ROLE_NAME" \
        --policy-arn "$POLICY_ARN" 2>/dev/null || echo -e "${YELLOW}  Already attached${NC}"
done

echo -e "${GREEN}✅ Policies attached${NC}"
echo ""

# Step 4: Create inline policy for additional permissions
echo "📋 Step 4: Creating inline policy for additional permissions..."

cat > inline-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam put-role-policy \
    --role-name "$IAM_ROLE_NAME" \
    --policy-name "GitHubActionsAdditionalPermissions" \
    --policy-document file://inline-policy.json

echo -e "${GREEN}✅ Inline policy attached${NC}"
echo ""

# Save role ARN
echo "export IAM_ROLE_ARN=\"$ROLE_ARN\"" >> aws-config.env

echo "================================================"
echo "   IAM Role Setup Complete"
echo "================================================"
echo ""
echo "Role ARN: $ROLE_ARN"
echo ""
echo -e "${GREEN}Important: Add this to your GitHub Secrets:${NC}"
echo "  Secret Name: AWS_ROLE_ARN"
echo "  Secret Value: $ROLE_ARN"
echo ""
echo "Next step: Run ./aws-verify-setup.sh to test the configuration"
echo ""
