# MCP Problem Solving Guide

## Overview

This comprehensive guide addresses common issues with Model Capability Providers (MCPs) in the Xwander AI Platform. MCPs extend Claude Code functionality by adding specialized capabilities through external services. When MCPs malfunction, they can prevent Claude Code from utilizing critical features.

## Common MCP Issues

1. **Registration Problems**: MCPs fail to register with Claude Code
2. **JSON Protocol Errors**: Malformed JSON or protocol version conflicts
3. **Persistence Issues**: MCP registrations persist between sessions when they shouldn't
4. **Integration Failures**: Claude Code can't communicate with MCP services
5. **Stale Cache**: Corrupted or outdated cache files prevent proper MCP operation

## Comprehensive Diagnostics

Before attempting to fix MCP issues, use the MCP Trace Utility to identify problems:

```bash
sudo /var/www/mcp-trace-cleanup.sh
```

This script provides:
- A list of all MCP-related files on your system
- Identification of problematic MCPs
- Analysis of JSON protocol issues
- Details on running MCP processes
- A comprehensive report of recommended actions

## Complete MCP Reset Procedure

When experiencing severe MCP issues, follow this step-by-step resolution procedure:

### Step 1: Stop All Claude and MCP Processes

```bash
# Find running Claude and MCP processes
ps aux | grep -i "claude\|mcp\|anthropic" | grep -v grep

# Kill them (replace PIDs with actual process IDs)
kill -9 <PID1> <PID2> <PID3>
```

### Step 2: Clear All MCP JSON Configuration Files

The most common issue with MCPs is corrupted JSON configuration files:

```bash
# Find all MCP JSON files
find / -name "*.mcp.json" -o -name "*.mcp-*.json" -o -name "mcp-server-registry.json" 2>/dev/null

# Clear all MCP registrations (replace paths with actual files found)
echo '{"mcps":[]}' > /path/to/file.mcp.json
echo '{"mcps":[]}' > ~/.config/claude-code/mcp-server-registry.json
echo '{"mcps":[]}' > /var/www/.mcp.json
```

### Step 3: Remove Claude CLI Cache

Claude maintains a cache that can become corrupted:

```bash
# Remove the entire Claude CLI cache directory
rm -rf ~/.cache/claude-cli-nodejs

# Remove Anthropic configuration directory
rm -rf ~/.anthropic
```

### Step 4: Clean NPM Cache

```bash
# Clear NPM cache 
npm cache clean --force
```

### Step 5: Update MCP Wrapper Scripts

Problematic MCP wrapper scripts can be temporarily disabled:

```bash
# Replace Python wrapper scripts
find /var/www/mcp-wrappers -name "*-mcp-wrapper.py" -exec bash -c '
echo "#!/usr/bin/env python3
import sys
print(\"ERROR: MCP disabled and not available\", file=sys.stderr)
sys.exit(1)" > {}' \;

# Replace Node.js wrapper scripts
find /var/www/mcp-wrappers -name "*-mcp-wrapper.js" -exec bash -c '
echo "#!/usr/bin/env node
console.error(\"ERROR: MCP disabled and not available\");
process.exit(1);" > {}' \;
```

### Step 6: Reinstall Claude CLI

```bash
# Uninstall Claude CLI
npm uninstall -g @anthropic-ai/claude-cli

# Reinstall Claude CLI
npm install -g @anthropic-ai/claude-cli
```

### Step 7: Check for Ports Used by MCPs

```bash
# Check for services running on common MCP ports
netstat -tuln | grep -E '3000|8000|8080' | grep LISTEN
```

## Automated Fix Script

For a complete automated solution, run:

```bash
sudo /var/www/fix-claude-mcps.sh
```

This script performs all the above steps and more:
- Creates backups of all MCP-related files
- Finds and clears all MCP JSON files
- Removes Claude CLI cache
- Updates MCP wrapper scripts
- Terminates running Claude/MCP processes
- Reinstalls Claude CLI
- Checks for system-wide configurations

## MCP Registration Best Practices

To prevent future issues, follow these best practices:

### 1. Register MCPs with Proper Scope

```bash
# For user-specific MCPs
claude mcp add --scope user

# For project-specific MCPs
claude mcp add --scope project
```

### 2. Verify MCP Health Before Registration

```bash
# Check MCP health endpoint
curl http://localhost:PORT/health
```

### 3. Use JSON Format for Registration

```bash
# Register MCP with JSON (prevents protocol errors)
claude mcp add-json user '{"name":"Example MCP","url":"https://example.com/mcp"}'
```

### 4. Implement Proper MCP Response Format

All MCP servers should follow the Xwander AI Platform standard response format:

```json
{
  "result": "<output data>",
  "token_usage": {
    "input_tokens": <number>,
    "output_tokens": <number>,
    "total_tokens": <number>
  },
  "processing_time_ms": <number>,
  "model": {
    "name": "<model name>",
    "version": "<model version>"
  }
}
```

### 5. Implement Required Endpoints

Every MCP server must implement:
- `/health` (GET) - Returns server health status
- `/process` (POST) - Processes a single request

## Troubleshooting Specific Issues

### Issue: MCPs still appear after removal

```bash
# Verify all Claude processes are stopped
pkill -f "node.*claude"

# Clear all caches
rm -rf ~/.cache/claude-cli-nodejs
rm -rf ~/.anthropic

# Check for environment variables
env | grep -i "claude\|mcp\|anthropic"

# Reboot the system if necessary
sudo reboot
```

### Issue: MCP timeout during registration

```bash
# Set longer timeout for MCP operations
export MCP_TIMEOUT=30000
```

### Issue: Authentication errors with MCPs

```bash
# Check for expired API keys or tokens
# Reauthenticate with Claude
claude auth login
```

### Issue: Debug MCP communication issues

```bash
# Enable MCP debugging
claude --mcp-debug
```

## After Fixing MCPs

After following the reset procedure:

1. **Close all terminal windows** to ensure complete environment reset
2. Open a new terminal window
3. Run `claude auth login` to reauthenticate
4. Verify with `claude /mcp` to check if MCPs are properly cleared
5. Selectively re-register only the MCPs you need

## Preventing Future Issues

1. **Regular Maintenance**: Run the cleanup script monthly
2. **Careful Registration**: Only register trusted and tested MCPs
3. **Clean Sessions**: Start fresh sessions for different projects
4. **Documentation**: Keep a record of which MCPs you need for specific tasks
5. **Version Control**: Track MCP changes and stick to stable versions

## Reference: MCP Architecture Standard

The Xwander AI Platform MCP architecture follows these standards:

1. **API Endpoints**:
   - `/health` (GET): Health check endpoint
   - `/` (GET): Basic service information
   - `/process` (POST): Process a single request
   
2. **Response Format**:
   - Standard JSON structure for all responses
   - Error handling with appropriate HTTP status codes
   
3. **Docker Configuration**:
   - Consistent container naming
   - Health check configuration
   - Network setup for Traefik integration

4. **MCP Registration Process**:
   - Service discovery via Registry
   - Capability declaration
   - Health status monitoring

Following these standards ensures smooth integration between Claude Code and MCP services.

## Conclusion

This guide provides comprehensive solutions for MCP-related issues in the Xwander AI Platform. By following these steps, you can effectively troubleshoot and resolve MCP problems, ensuring smooth operation of Claude Code and its integrated services.

For further assistance, refer to the [Claude Code documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) or contact the Xwander AI Platform support team.