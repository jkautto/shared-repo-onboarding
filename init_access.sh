#!/bin/bash

# Initialization script for accessing the shared tools repository
# Usage: ./init_access.sh GITHUB_TOKEN

set -e  # Exit immediately if a command fails

if [ $# -ne 1 ]; then
    echo "Error: GitHub token required"
    echo "Usage: ./init_access.sh GITHUB_TOKEN"
    exit 1
fi

TOKEN=$1
PRIVATE_REPO="jkautto/kaut-shared"
TARGET_DIR="./kaut-shared-tools"

echo "======================================================"
echo "  Shared Tools Access - Initialization Script"
echo "======================================================"
echo 
echo "This script will clone the private repository:"
echo "https://github.com/$PRIVATE_REPO"
echo 
echo "Verifying token access..."

# Test token access to the repository
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $TOKEN" "https://api.github.com/repos/$PRIVATE_REPO")

if [ "$HTTP_STATUS" != "200" ]; then
    echo "ERROR: Cannot access the private repository."
    echo "Status code: $HTTP_STATUS"
    echo 
    echo "Possible reasons:"
    echo "- Invalid GitHub token"
    echo "- Token does not have access to $PRIVATE_REPO"
    echo "- Repository doesn't exist or network issue"
    echo 
    echo "Please contact your system administrator."
    exit 1
fi

echo "✅ Token verified successfully!"
echo "Creating target directory: $TARGET_DIR"

# Create target directory (and parent directories if needed)
mkdir -p "$TARGET_DIR"

echo "Cloning private repository..."
echo "https://github.com/$PRIVATE_REPO -> $TARGET_DIR"

# Clone the repository (quiet mode)
git clone -q "https://oauth2:${TOKEN}@github.com/$PRIVATE_REPO" "$TARGET_DIR"

if [ $? -eq 0 ]; then
    echo 
    echo "======================================================"
    echo "✅ SUCCESS! Shared tools repository cloned successfully."
    echo "======================================================"
    echo 
    echo "The shared tools are now available in: $TARGET_DIR"
    echo 
    echo "NEXT STEPS:"
    echo "1. Read the documentation: $TARGET_DIR/docs/README.md"
    echo "2. Set up aliases: source $TARGET_DIR/bin/setup_aliases.sh"
    echo "3. Start using the tools"
    echo 
    echo "For help, see: $TARGET_DIR/docs/GETTING_STARTED.md"
    echo "======================================================"
else
    echo 
    echo "======================================================"
    echo "❌ ERROR: Failed to clone the repository."
    echo "======================================================"
    echo 
    echo "Please try the direct method:"
    echo "git clone https://oauth2:${TOKEN}@github.com/$PRIVATE_REPO $TARGET_DIR"
    echo 
    echo "If that fails, contact your system administrator."
    echo "======================================================"
    exit 1
fi

exit 0