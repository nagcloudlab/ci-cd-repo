#!/bin/bash
# AWS OIDC Setup Configuration
# Run this script to collect necessary information

set -e

echo "================================================"
echo "   AWS OIDC Setup for GitHub Actions"
echo "================================================"
echo ""

# Get AWS Account ID
echo "📊 Getting your AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"
echo ""

# Get current region
echo "📍 Getting your current AWS region..."
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="ap-south-1"  # Default to Mumbai
    echo "⚠️  No region configured, using default: $AWS_REGION"
else
    echo "✅ Current region: $AWS_REGION"
fi
echo ""

# Get GitHub repository information
echo "🐙 GitHub Repository Information"
echo "Enter your GitHub username or organization:"
read -p "GitHub Owner: " GITHUB_OWNER
echo ""

echo "Enter your repository name (e.g., npci-transfer-service):"
read -p "Repository Name: " GITHUB_REPO
echo ""

# Confirm information
echo "================================================"
echo "   Configuration Summary"
echo "================================================"
echo "AWS Account ID:     $AWS_ACCOUNT_ID"
echo "AWS Region:         $AWS_REGION"
echo "GitHub Owner:       $GITHUB_OWNER"
echo "GitHub Repository:  $GITHUB_REPO"
echo "Full Repo Path:     $GITHUB_OWNER/$GITHUB_REPO"
echo "================================================"
echo ""

read -p "Is this information correct? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Setup cancelled. Please run the script again."
    exit 1
fi

# Save configuration
cat > aws-config.env << EOF
# AWS OIDC Configuration
# Generated on $(date)

export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"
export AWS_REGION="$AWS_REGION"
export GITHUB_OWNER="$GITHUB_OWNER"
export GITHUB_REPO="$GITHUB_REPO"
export GITHUB_REPO_FULL="$GITHUB_OWNER/$GITHUB_REPO"
export IAM_ROLE_NAME="GitHubActions-NPCI-Role"
export OIDC_PROVIDER_URL="token.actions.githubusercontent.com"
EOF

echo ""
echo "✅ Configuration saved to: aws-config.env"
echo ""
echo "Next steps:"
echo "1. Run: source aws-config.env"
echo "2. Run: ./aws-create-oidc-provider.sh"
echo ""
