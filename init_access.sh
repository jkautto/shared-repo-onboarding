#!/bin/bash

# Initialization script for shared resource access
# Usage: ./init_access.sh GITHUB_TOKEN

if [ $# -ne 1 ]; then
    echo "Error: GitHub token required"
    echo "Usage: ./init_access.sh GITHUB_TOKEN"
    exit 1
fi

TOKEN=$1

echo "Verifying access credentials..."
# Verify token has access to the repository
curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $TOKEN" https://api.github.com/repos/jkautto/kaut-shared > /tmp/curl_response.txt
RESPONSE=$(cat /tmp/curl_response.txt)
rm /tmp/curl_response.txt

if [ "$RESPONSE" != "200" ]; then
    echo "Error: Invalid token or repository access denied"
    echo "HTTP response: $RESPONSE"
    exit 1
fi

echo "Access verified successfully."
echo "Cloning shared tools repository..."

# Create a target directory for the repository
SHARED_DIR="./kaut-shared-tools"
mkdir -p $SHARED_DIR

# Clone the repository using the token
git clone https://oauth2:${TOKEN}@github.com/jkautto/kaut-shared.git $SHARED_DIR

if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository"
    exit 1
fi

echo ""
echo "======================================================"
echo "✅ Shared tools repository successfully connected!"
echo "======================================================"
echo ""
echo "REPOSITORY: kaut-shared (private)"
echo "LOCATION: $SHARED_DIR"
echo "DOCUMENTATION: $SHARED_DIR/docs/README.md"
echo ""
echo "Next steps:"
echo "1. Read $SHARED_DIR/docs/README.md for setup instructions"
echo "2. Set up aliases for context management tools:"
echo "   source $SHARED_DIR/bin/setup_aliases.sh"
echo "3. Test context management tools using the /pc and /ac commands"
echo ""
echo "For more information, check $SHARED_DIR/docs/GETTING_STARTED.md"
echo "======================================================"

exit 0