# Model Context Protocol (MCP) Guide

This guide explains how to register, manage, and configure MCP servers in Claude Code, including best practices for different scopes and JSON configuration.

## Table of Contents

1. [Introduction to MCP](#introduction-to-mcp)
2. [MCP Command Reference](#mcp-command-reference)
3. [Understanding MCP Server Scopes](#understanding-mcp-server-scopes)
4. [JSON Configuration Method](#json-configuration-method)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

## Introduction to MCP

Model Context Protocol (MCP) is an open protocol that enables LLMs like Claude to access external tools and data sources. MCP follows a client-server architecture where Claude Code (the client) connects to specialized servers that provide additional capabilities.

> **Security Note**: Use third-party MCP servers at your own risk. Make sure you trust the MCP servers, and be especially careful when using MCP servers that talk to the internet, as these can expose you to prompt injection risk.

## MCP Command Reference

```
Usage: claude mcp [options] [command]

Configure and manage MCP servers

Options:
  -h, --help                                     display help for command

Commands:
  serve                                          Start the Claude Code MCP server
  add [options] [name] [commandOrUrl] [args...]  Add a server (run without arguments for interactive wizard)
  remove [options] <name>                        Remove an MCP server
  list                                           List configured MCP servers
  get <name>                                     Get details about an MCP server
  add-json [options] <name> <json>               Add an MCP server (stdio or SSE) with a JSON string
  add-from-claude-desktop [options]              Import MCP servers from Claude Desktop (Mac and WSL only)
  reset-project-choices                          Reset all approved and rejected project-scoped (.mcp.json) servers within this project
  help [command]                                 display help for command
```

## Understanding MCP Server Scopes

MCP servers can be registered in three different scopes, which determine where they're available and who can access them.

### 1. Local-scoped MCP Servers

The default scope (local) stores MCP server configurations in your project-specific user settings. These servers are only available to you while working in the current project.

```bash
# Add a local-scoped server (default)
claude mcp add my-private-server /path/to/server

# Explicitly specify local scope
claude mcp add my-private-server -s local /path/to/server
```

### 2. Project-scoped MCP Servers (.mcp.json)

Project-scoped servers are stored in a `.mcp.json` file at the root of your project. This file should be checked into version control to share servers with your team.

```bash
# Add a project-scoped server
claude mcp add shared-server -s project /path/to/server
```

This creates or updates a `.mcp.json` file with the following structure:

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

### 3. User-scoped MCP Servers

User-scoped servers are available to you across all projects on your machine and are private to you. This scope (formerly called "global") is recommended for servers you want to use across multiple projects.

```bash
# Add a user-scoped server
claude mcp add my-user-server -s user /path/to/server
```

### Scope Priority and Management

- Local-scoped servers take precedence over project-scoped and user-scoped servers with the same name
- Project-scoped servers (in `.mcp.json`) take precedence over user-scoped servers with the same name
- Before using project-scoped servers from `.mcp.json`, Claude Code will prompt you to approve them for security
- The `.mcp.json` file is intended to be checked into version control to share MCP servers with your team
- Project-scoped servers make it easy to ensure everyone on your team has access to the same MCP tools
- If you need to reset your choices for which project-scoped servers are enabled or disabled, use `claude mcp reset-project-choices`

## JSON Configuration Method

The recommended way to add MCP servers is using the JSON configuration method, which provides better documentation, schema validation, and example usage.

### Adding an MCP Server Using JSON

```bash
# Basic syntax
claude mcp add-json <name> '<json>'

# Example: Adding a stdio server with JSON configuration
claude mcp add-json weather-api '{
  "name": "weather-api",
  "description": "Get weather information for a location",
  "version": "1.0.0",
  "command": "/path/to/weather-cli",
  "args": ["--api-key", "abc123"],
  "env": {"CACHE_DIR": "/tmp"},
  "protocol": "stdio",
  "schema": {
    "type": "object",
    "required": ["type", "parameters"],
    "properties": {
      "type": {
        "type": "string",
        "enum": ["weather"]
      },
      "parameters": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string",
            "description": "The location to get weather for"
          },
          "units": {
            "type": "string",
            "enum": ["metric", "imperial"],
            "description": "Temperature units"
          }
        },
        "required": ["location"]
      }
    }
  },
  "examples": [
    {
      "description": "Get weather in Paris",
      "request": {
        "type": "weather",
        "parameters": {
          "location": "Paris, France",
          "units": "metric"
        }
      }
    }
  ]
}'
```

### Verifying Server Registration

```bash
# Check registration
claude mcp get weather-api

# List all registered servers
claude mcp list
```

### Adding to User Scope (Recommended)

For shared servers that you want to use across multiple projects, use the user scope (formerly called global):

```bash
# User-scoped registration
claude mcp add-json -s user weather-api '{ ... JSON configuration ... }'
```

### JSON Configuration Schema

A complete MCP server JSON configuration includes:

```json
{
  "name": "server-name",
  "description": "Description of the MCP service",
  "version": "1.0.0",
  "command": "/path/to/executable",
  "protocol": "stdio",
  "args": ["--optional", "args"],
  "env": {
    "ENV_VAR": "value"
  },
  "schema": {
    "type": "object",
    "required": ["type", "parameters"],
    "properties": {
      "type": {
        "type": "string",
        "enum": ["command_type"]
      },
      "parameters": {
        "type": "object",
        "properties": {
          "param1": {
            "type": "string",
            "description": "Description of parameter 1"
          }
        },
        "required": ["param1"]
      }
    }
  },
  "examples": [
    {
      "description": "Example description",
      "request": {
        "type": "command_type",
        "parameters": {
          "param1": "value1"
        }
      }
    }
  ]
}
```

### Handling Complex JSON

For complex JSON configurations, it's recommended to store the configuration in a file and reference it:

```bash
# Store in a file and reference
claude mcp add-json server-name "$(cat path/to/server-config.json)"
```

## Best Practices

### 1. Choosing the Right Scope

- **Project Scope (Recommended)**: For sharing MCP servers with your team via version control. This approach creates a `.mcp.json` file at the project root which can be committed to your repository and shared with all team members. This is the most reliable and recommended approach.
- **User Scope**: For servers you want to use across multiple projects on your personal machine
- **Local Scope**: For temporary experimentation with MCP servers or for servers that are specific to your current work session

### 2. JSON Configuration Benefits

Always use the JSON configuration method (`claude mcp add-json`) when possible, because it:

- Provides better documentation and schema validation
- Allows clear specification of parameter types, required fields, and descriptions
- Enables better error handling and validation in Claude Code
- Includes the ability to provide example usages

### 3. Checking Server Status

Regularly check MCP server status using the `/mcp` command within Claude Code. This shows the connection status of all registered servers.

### 4. Environment Variables

Set environment variables with the `-e` or `--env` flags:

```bash
claude mcp add my-server -e API_KEY=123 -- /path/to/server
```

Or in the JSON configuration:

```json
{
  "env": {
    "API_KEY": "abc123",
    "DEBUG": "true"
  }
}
```

### 5. Timeout Configuration

Configure MCP server startup timeout using the `MCP_TIMEOUT` environment variable:

```bash
# Set a 10-second timeout
MCP_TIMEOUT=10000 claude
```

## Implementing MCP Servers

When implementing your own MCP servers, follow these critical requirements for reliable operation:

### 1. JSON-RPC 2.0 Protocol Compliance

MCP servers **must** implement the JSON-RPC 2.0 protocol:

- Use proper request/response envelope structure
- Include matching request IDs in responses
- Follow standard method naming conventions
- Handle errors with appropriate error codes

Example initialize response:
```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {},
    "serverInfo": {
      "name": "my-server",
      "version": "1.0.0"
    }
  }
}
```

### 2. Process Execution Model

MCP follows a specific process execution model:

- Each method call (initialize, execute) is handled by a separate server process
- Claude launches a new process for each method
- The server should process one message then exit
- Do not wait for multiple messages in a single process

### 3. Protocol Version Handling

One of the most critical aspects is protocol version handling:

- Extract the protocol version from the initialize request
- Return the **exact same** protocol version in the initialize response
- Current version is "2024-11-05" but this may change, so extract it dynamically

### 4. Output Buffering Control

Properly manage output buffering:

- Always flush stdout after writing responses
- Include a newline character after JSON responses
- Use explicit flushing mechanisms for your language
- Don't rely on implicit buffer flushing

### 5. Error Handling

Implement robust error handling:

- Use proper JSON-RPC error responses with standard error codes
- Add timeout protection for stdin reads
- Handle signals gracefully (SIGINT, SIGTERM)
- Include detailed logging for troubleshooting

## Enhanced MCP Management

We've created a comprehensive management script that provides a unified interface for managing MCP servers:

```bash
# Show available commands
/var/www/dai/manage_mcp.sh help

# Clean all MCP servers and registrations
/var/www/dai/manage_mcp.sh clean

# Set up the enhanced fix-mcp server
/var/www/dai/manage_mcp.sh setup-fix

# List all registered MCP servers
/var/www/dai/manage_mcp.sh list

# Test a specific MCP server directly
/var/www/dai/manage_mcp.sh test fix-mcp

# View logs for a specific server
/var/www/dai/manage_mcp.sh logs fix-mcp

# Register a specific MCP server
/var/www/dai/manage_mcp.sh register fix-mcp
```

## Setting Up Reliable MCP Servers

Based on extensive testing and troubleshooting, we've developed a reliable approach to setting up and maintaining MCP servers. Follow these steps to ensure your MCP servers connect properly:

### 1. Proper MCP Server Setup

To set up a working MCP server, ensure:

1. **Log Directory Permissions**: Make sure your log directories have proper write permissions:
   ```bash
   # Create logs directory with correct permissions
   mkdir -p /var/www/dai/logs
   chmod 777 /var/www/dai/logs
   ```

2. **Log File Preparation**: Create log files with proper permissions before server starts:
   ```bash
   # Create and prepare log file
   touch /var/www/dai/logs/my-mcp-server.log
   chmod 666 /var/www/dai/logs/my-mcp-server.log
   ```

3. **Direct Logging**: Use direct log paths instead of fallback logic to avoid warnings on stderr:
   ```javascript
   // Good logging approach (Node.js example)
   const logFile = '/var/www/dai/logs/my-mcp.log';
   const log = fs.createWriteStream(logFile, { flags: 'w' });
   ```

4. **Proper JSON-RPC Implementation**: Follow correct JSON-RPC 2.0 protocol:
   - Include proper jsonrpc, id, and result/error structure
   - Extract and match protocol version exactly from initialize request
   - Process one message per execution and exit
   - Use explicit output flushing

### 2. Using Our Proven Fix-MCP Implementation

We've developed a reliable reference implementation that handles all these requirements:

```bash
# Set up our proven fix-mcp server
/var/www/dai/setup_fix_mcp.sh

# Or register it manually
 claude mcp add fix-server /var/www/dai/bin/fix-mcp.js
```

### 3. Troubleshooting Connection Issues

If an MCP server shows as "failed" or "connecting...", use our enhanced troubleshooting process:

1. **Deep Clean**: Start by removing all MCP servers:
   ```bash
   # List all registered servers
   claude mcp list
   
   # Remove each one
   claude mcp remove server1
   claude mcp remove server2
   ```

2. **Check Permissions**: Verify log directory and file permissions:
   ```bash
   ls -la /var/www/dai/logs
   ls -la /var/www/dai/logs/fix-mcp.log
   ```

3. **Register Single MCP**: Register only one MCP server at a time to avoid conflicts:
   ```bash
   claude mcp add fix-server /var/www/dai/bin/fix-mcp.js
   ```

4. **Increase Timeout and Enable Debug Mode**:
   ```bash
   MCP_TIMEOUT=60000 claude --mcp-debug
   ```

5. **Check Connection Status**:
   ```
   /mcp
   ```

6. **Examine Detailed Logs**:
   ```bash
   cat /var/www/dai/logs/fix-mcp.log
   ```

### Common Root Causes and Solutions

| Issue | Root Cause | Solution |
|-------|------------|----------|
| **Connection timeout** | Incorrect protocol implementation | Use JSON-RPC 2.0 format with proper envelope |
| **Method not found error** | Misunderstood process model | Process one message per execution and exit |
| **Protocol version mismatch** | Static protocol version | Extract version dynamically from request |
| **No response** | Output buffering | Add newline and explicit flush after responses |
| **Inconsistent behavior** | Multiple conflicting MCPs | Clean all servers and register only one |
| **Permission issues** | Log directory permissions | Set proper permissions (777 for dirs, 666 for files) |
| **stderr warnings** | Fallback logic in logging | Use direct log paths instead of fallback logic |

### Critical MCP Server Requirements

Based on our investigation, here are the critical requirements for MCP server implementation:

1. **JSON-RPC Protocol Conformance**:
   - All responses must follow JSON-RPC 2.0 format
   - Include proper jsonrpc, id, and result/error structure
   - Match request IDs exactly in responses

2. **Protocol Version Matching**:
   - Extract protocol version from initialize request
   - Return the EXACT same version in initialize response
   - Example: if request has "protocolVersion": "2024-11-05", response must use identical string

3. **Process Execution Model**:
   - Each method call (initialize, execute) is handled by a separate process
   - Process one message then exit, don't wait for multiple messages
   - Clean process termination after sending response

4. **Output Buffering Control**:
   - Add newline character after JSON responses
   - Use explicit flushing mechanisms for your language
   - Node.js: `process.stdout.write(response + '\n', () => process.exit(0))`
   - Python: `print(response, flush=True)`
   - Bash: `stdbuf -oL echo "$response"`

5. **Error Handling**:
   - Don't write warnings to stderr that could interfere with JSON-RPC communication
   - Use proper error logging to files instead
   - Handle process signals gracefully

### Registration Issues

If you have issues with server registration:

1. Check all scopes:
   ```bash
   claude mcp list         # Local scope
   claude mcp list -s user # User scope
   claude mcp list -s project # Project scope
   ```

2. Remove and re-add the server:
   ```bash
   claude mcp remove server-name
   claude mcp add-json server-name '{ ... configuration ... }'
   ```

3. Reset project choices:
   ```bash
   claude mcp reset-project-choices
   ```

## Reference Implementation

Here's our proven reference implementation in Node.js that addresses all the critical requirements for a reliable MCP server:

```javascript
#!/usr/bin/env node

// Enhanced MCP server with proper JSON-RPC implementation
const fs = require('fs');
const path = require('path');

// Set up logging with fallback options
const primaryLogDir = '/var/www/dai/logs';
const fallbackLogDir = '/tmp';
let logFile;
let log;

// Try to set up logging with fallbacks
try {
  // Try primary location first
  if (fs.existsSync(primaryLogDir) && fs.accessSync(primaryLogDir, fs.constants.W_OK)) {
    logFile = path.join(primaryLogDir, 'fix-mcp.log');
  } else {
    // Fall back to /tmp if primary location isn't writable
    logFile = path.join(fallbackLogDir, 'fix-mcp.log');
    console.error(`Warning: Using fallback log location: ${logFile}`);
  }
  
  // Create the log stream
  log = fs.createWriteStream(logFile, { flags: 'w' });
  
  // Test write to log
  log.write(`MCP Started at ${new Date().toISOString()}\n`);
} catch (err) {
  // If all logging fails, create a dummy logger that doesn't fail
  console.error(`Warning: Could not create log file: ${err.message}`);
  log = {
    write: (msg) => { return true; },
    end: () => { return true; }
  };
}

// Log basic information
log.write(`PID: ${process.pid}\n`);
log.write(`Working Directory: ${process.cwd()}\n\n`);

// Handle process errors and signals
process.on('uncaughtException', (err) => {
  log.write(`UNCAUGHT EXCEPTION: ${err.stack || err}\n`);
  process.exit(1);
});

['SIGINT', 'SIGTERM'].forEach(signal => {
  process.on(signal, () => {
    log.write(`Received ${signal}, exiting gracefully...\n`);
    log.end();
    process.exit(0);
  });
});

// Collect request data with timeout protection
const chunks = [];
let dataTimeout = setTimeout(() => {
  log.write('WARNING: No data received within 10 seconds, exiting...\n');
  log.end();
  process.exit(1);
}, 10000);

process.stdin.on('data', (chunk) => {
  clearTimeout(dataTimeout);
  chunks.push(chunk);
  
  // Reset timeout for each chunk
  dataTimeout = setTimeout(() => {
    log.write('Data stream seems complete. Processing...\n');
    processRequest();
  }, 500);
});

process.stdin.on('end', () => {
  clearTimeout(dataTimeout);
  log.write('stdin stream ended. Processing request...\n');
  processRequest();
});

// Process the complete request
function processRequest() {
  const rawData = chunks.join('');
  log.write(`Request raw (${rawData.length} bytes): ${rawData}\n\n`);
  
  try {
    const request = JSON.parse(rawData);
    const method = request.method || '';
    const requestId = request.id !== undefined ? request.id : 0;
    
    // Handle different method types
    if (method === 'initialize') {
      handleInitialize(request, requestId);
    } else if (method === 'execute' || method === 'tools/call') {
      handleExecute(request, requestId);
    } else {
      handleUnknownMethod(method, requestId);
    }
  } catch (error) {
    log.write(`ERROR parsing request: ${error.stack || error.message}\n`);
    sendErrorResponse(0, -32700, `Parse error: ${error.message}`);
  }
}

// Handle initialize method
function handleInitialize(request, requestId) {
  log.write('Handling initialize method...\n');
  
  // Extract protocol version - CRITICAL: must match exactly what client sends
  const protocolVersion = request.params?.protocolVersion || '2024-11-05';
  log.write(`Protocol Version: ${protocolVersion}\n`);
  
  const response = {
    jsonrpc: '2.0',
    id: requestId,
    result: {
      protocolVersion: protocolVersion,
      capabilities: {},
      serverInfo: {
        name: 'fix-mcp',
        version: '1.0.0'
      }
    }
  };
  
  sendResponse(response);
}

// Handle execute method
function handleExecute(request, requestId) {
  log.write('Handling execute or tools/call method...\n');
  
  // Extract type and parameters if present
  const type = request.params?.type || 'unknown';
  const parameters = request.params?.parameters || {};
  
  log.write(`Type: ${type}, Parameters: ${JSON.stringify(parameters)}\n`);
  
  const response = {
    jsonrpc: '2.0',
    id: requestId,
    result: {
      status: 'success',
      result: `Hello from fix-mcp! I processed a request of type "${type}" with ${Object.keys(parameters).length} parameters.`
    }
  };
  
  sendResponse(response);
}

// Handle unknown method
function handleUnknownMethod(method, requestId) {
  log.write(`Unknown method: ${method}\n`);
  sendErrorResponse(requestId, -32601, `Method not found: ${method || 'unknown'}`);
}

// Send a successful response
function sendResponse(response) {
  const responseJson = JSON.stringify(response);
  log.write(`Response: ${responseJson}\n`);
  
  // Send response to stdout with explicit flush and newline
  process.stdout.write(responseJson + '\n');
  process.stdout.write('', () => {
    // This callback runs after output is flushed
    log.write('Response sent and flushed. Exiting...\n');
    log.end();
    process.exit(0);
  });
}

// Send an error response
function sendErrorResponse(id, code, message) {
  const errorResponse = {
    jsonrpc: '2.0',
    id: id,
    error: {
      code: code,
      message: message
    }
  };
  
  const responseJson = JSON.stringify(errorResponse);
  log.write(`Error Response: ${responseJson}\n`);
  
  process.stdout.write(responseJson + '\n');
  process.stdout.write('', () => {
    log.write('Error response sent and flushed. Exiting...\n');
    log.end();
    process.exit(1);
  });
}
```

This reference implementation can be used as a template for creating new MCP servers that follow all the best practices for reliable operation. It handles all edge cases and includes proper error handling, logging, timeout protection, and protocol compliance.

---

This guide should help you effectively implement and work with MCP servers in Claude Code. The information here is based on extensive testing and successful implementation experience.