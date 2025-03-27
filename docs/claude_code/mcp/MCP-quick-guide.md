# MCP Quick Guide

This guide provides essential instructions for properly setting up and troubleshooting Model Context Protocol (MCP) servers with Claude Code.

## Quick Reference

### MCP Server Registration

```bash
# Add a server to local scope (default)
claude mcp add server-name /path/to/executable

# Remove a server
claude mcp remove server-name

# List registered servers
claude mcp list

# Reset project choices (for .mcp.json servers)
claude mcp reset-project-choices
```

### Project-Scoped MCP Setup (.mcp.json)

Create a `.mcp.json` file in your project root:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "/absolute/path/to/executable",
      "args": [],
      "env": {}
    }
  }
}
```

This allows sharing MCP servers with your team via version control.

## Critical Requirements for MCP Servers

1. **JSON-RPC 2.0 Protocol**
   - All responses must use proper JSON-RPC 2.0 format
   - Include jsonrpc, id, and result/error structure
   - Match request IDs in responses

2. **Protocol Version Matching**
   - Extract protocol version from initialize request
   - Return EXACT same protocol version in response
   - Current version is "2024-11-05" but extract dynamically

3. **Process Execution Model**
   - Each method call (initialize, execute) is handled by a separate process
   - Process one message per execution and exit
   - Do not wait for multiple messages in one process

4. **Output Buffering**
   - Use explicit flushing after responses
   - Add newline character after JSON responses
   - Avoid implicit buffer flushing

5. **Permissions**
   - Log directory needs 777 permissions
   - Log files need 666 permissions

## MCP Implementation Example (Bash)

```bash
#!/bin/bash
# Simple JSON-RPC compliant MCP server
logfile="/path/to/logs/server.log"
echo "Started: $(date)" > "$logfile"
request=$(cat)
echo "Request: $request" >> "$logfile"

if [[ "$request" == *"initialize"* ]]; then
  # Extract protocol version from request
  if [[ "$request" =~ \"protocolVersion\":\"([^\"]+)\" ]]; then
    PROTOCOL_VERSION="${BASH_REMATCH[1]}"
  else
    PROTOCOL_VERSION="2024-11-05"
  fi
  echo "{\"jsonrpc\":\"2.0\",\"id\":0,\"result\":{\"protocolVersion\":\"$PROTOCOL_VERSION\",\"capabilities\":{},\"serverInfo\":{\"name\":\"my-server\",\"version\":\"1.0\"}}}" | tee -a "$logfile"
else
  echo "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"status\":\"success\",\"result\":\"Hello from MCP server\"}}" | tee -a "$logfile"
fi
echo "Ended: $(date)" >> "$logfile"
```

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Connection timeout | Ensure server follows JSON-RPC 2.0 protocol exactly |
| Protocol version mismatch | Extract protocol version from request and return exactly |
| Permissions errors | Set chmod 777 for log dirs, chmod 666 for log files |
| Multiple fails | Clean all servers, register one at a time |
| Response not received | Add newline and explicit flush after responses |

## Troubleshooting Steps

1. **Clean registration**
   ```bash
   # Remove existing servers
   claude mcp remove server1
   claude mcp remove server2
   
   # Reset project choices
   claude mcp reset-project-choices
   ```

2. **Fix permissions**
   ```bash
   # Create logs directory with proper permissions
   mkdir -p /var/www/project/logs
   chmod 777 /var/www/project/logs
   
   # Create log files with proper permissions
   touch /var/www/project/logs/server.log
   chmod 666 /var/www/project/logs/server.log
   ```

3. **Use extended timeout**
   ```bash
   MCP_TIMEOUT=60000 claude --mcp-debug
   ```

4. **Check connection status**
   ```
   /mcp
   ```

5. **Examine logs**
   ```bash
   cat /var/www/project/logs/server.log
   ```

## Testing MCP Server Directly

```bash
# Test initialize method
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"claude","version":"0.1.0"}}}' | /path/to/mcp-server

# Test execute method
echo '{"jsonrpc":"2.0","id":1,"method":"execute","params":{"type":"test","parameters":{"name":"Test"}}}' | /path/to/mcp-server
```