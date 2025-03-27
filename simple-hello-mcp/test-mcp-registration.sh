#!/bin/bash

# Test MCP Registration Script
# Following the steps from MCP-PROBLEM-SOLVING.md

echo "===== TESTING SIMPLE HELLO WORLD MCP REGISTRATION ====="

# Step 1: Verify clean slate - check for any existing MCP registrations
echo "Step 1: Checking for existing MCP registrations..."
if [ -f ~/.config/claude-code/mcp-server-registry.json ]; then
    echo "Found existing MCP registry file:"
    cat ~/.config/claude-code/mcp-server-registry.json
else
    echo "No existing MCP registry file found - clean slate"
fi

# Step 2: Start our simple MCP server
echo "Step 2: Starting Simple Hello World MCP server..."
echo "Installing requirements first..."
pip install -r requirements.txt

# Start the server in the background
echo "Starting the MCP server..."
python app.py > ./logs/mcp.log 2>&1 &
MCP_PID=$!
echo "MCP server started with PID: $MCP_PID"

# Wait for server to start
echo "Waiting for server to initialize..."
sleep 5

# Step 3: Verify the MCP server is running
echo "Step 3: Verifying MCP server is operational..."
HEALTH_CHECK=$(curl -s http://localhost:3500/health)
echo "Health check response: $HEALTH_CHECK"

# Step 4: Register the MCP with Claude using best practices
echo "Step 4: Registering MCP with Claude..."
echo "Using JSON format for registration (prevents protocol errors)"
claude mcp add-json user '{"name":"Simple Hello World MCP","url":"http://localhost:3500"}'

# Step 5: Verify registration
echo "Step 5: Verifying MCP registration..."
claude mcp list

# Step 6: Test MCP functionality (optional - would be done in Claude Code)
echo "Step 6: To test the MCP functionality, run Claude Code and use:"
echo '
<function_calls>
<invoke name="SimpleHelloWorldMCP">
<parameter name="query">How are you today?</parameter>
</invoke>
</function_calls>
'

echo "===== TEST COMPLETE ====="
echo "To stop the MCP server: kill $MCP_PID"
echo "To remove this MCP: claude mcp remove <mcp-id>"