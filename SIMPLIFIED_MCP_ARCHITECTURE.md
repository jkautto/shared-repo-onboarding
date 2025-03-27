# Simplified MCP Architecture

> **Repository**: https://github.com/jkautto/dai

## Overview

This document outlines our simplified Model Context Protocol (MCP) architecture designed to eliminate Docker dependencies and create a more maintainable, efficient system for Claude Code integration.

## Key Benefits

- **Simplified Deployment**: No Docker dependencies, just Python and Bash
- **Lower Resource Usage**: Minimal overhead compared to containerized solutions
- **Easier Maintenance**: Simple structure with clear separation of concerns
- **Consistent Logging**: Standardized logging for easier troubleshooting
- **Simulation Mode**: Built-in support for offline/testing scenarios
- **Two-Level Architecture**: Global MCPs (shared) and project-specific MCPs

## Directory Structure

### Global MCPs (Shared Across Projects)

```
/var/www/mcp/
├── bin/                  # Executable wrapper scripts
│   ├── hello-world       # Hello World MCP wrapper
│   └── perplexity-search # Perplexity search MCP wrapper  
├── config/               # Configuration files
│   ├── hello_world_config.json
│   └── perplexity_config.json
├── core/                 # Core shared libraries
├── logs/                 # Log files
├── services/             # Service implementations
│   ├── hello_world_service.py
│   └── perplexity_service.py
└── templates/            # Templates for creating new MCPs
    ├── mcp_boilerplate.py
    └── mcp_wrapper.sh
```

### Project-Specific MCPs

```
/var/www/[project]/mcp/
├── bin/                  # Project-specific wrapper scripts
├── config/               # Project-specific configuration
├── logs/                 # Project-specific log files
├── servers/              # Service implementations
│   └── utils/            # Utility functions
└── templates/            # Project-specific templates
```

## Implementation Details

### 1. MCP Service Components

Each MCP consists of two primary components:

1. **Service Implementation** (Python): Handles the logic and processing
2. **Wrapper Script** (Bash): Manages I/O, logging, and error handling

### 2. MCP Registration

MCPs are registered using the Claude CLI:

```bash
claude mcp add <name> "/var/www/mcp/bin/<wrapper-script>"
```

For example:
```bash
claude mcp add hello-world "/var/www/mcp/bin/hello-world"
```

### 3. Communication Protocol

- Input is received as JSON on stdin
- Output is returned as JSON on stdout
- All logging is redirected to files to avoid interference with JSON communication

### 4. Configuration Management

- Each MCP has its own configuration file in `/var/www/mcp/config/`
- Default configuration is included in the service code
- Configuration path can be overridden via environment variables

### 5. Logging Strategy

- Dedicated log files for each MCP
- Consistent log format across all MCPs
- Log rotation to prevent disk space issues
- Debug information for requests and responses

## Creating a New MCP

### Step 1: Copy the Templates

```bash
# For the service implementation
cp /var/www/mcp/templates/mcp_boilerplate.py /var/www/mcp/services/your_service.py

# For the wrapper script
cp /var/www/mcp/templates/mcp_wrapper.sh /var/www/mcp/bin/your-mcp
```

### Step 2: Customize the Service Implementation

Edit `/var/www/mcp/services/your_service.py`:
- Update the class name and methods
- Implement your custom logic
- Configure logging
- Handle errors gracefully

### Step 3: Customize the Wrapper Script

Edit `/var/www/mcp/bin/your-mcp`:
- Update the service name
- Ensure paths are correct
- Make the script executable:
  ```bash
  chmod +x /var/www/mcp/bin/your-mcp
  ```

### Step 4: Create Configuration (Optional)

Create `/var/www/mcp/config/your_config.json` with appropriate settings.

### Step 5: Register with Claude Code

```bash
claude mcp add your-mcp "/var/www/mcp/bin/your-mcp"
```

### Step 6: Test Your MCP

```bash
echo '{"type": "your_type", "parameters": {"param1": "value1"}}' | /var/www/mcp/bin/your-mcp
```

## Hello World Example

We've created a simple Hello World MCP that demonstrates this architecture:

### Service Implementation

```python
# /var/www/mcp/services/hello_world_service.py
import json, logging, os, sys
from typing import Dict, Any, Optional

# Configure logging
log_dir = "/var/www/mcp/logs"
os.makedirs(log_dir, exist_ok=True)
logging.basicConfig(
    level=os.environ.get("MCP_LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler(f"{log_dir}/hello-world-mcp.log")]
)
logger = logging.getLogger("hello_world_mcp")

class HelloWorldMCP:
    def __init__(self, config_path: Optional[str] = None):
        self.name = "hello-world-mcp"
        self.config = self._load_config(config_path)
        logger.info(f"Initialized {self.name}")
    
    # Load configuration from file
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        if not config_path:
            return {"default_message": "Hello, World!"}
        try:
            with open(config_path, "r") as f:
                return json.load(f)
        except Exception as e:
            logger.warning(f"Could not load config: {e}")
            return {"default_message": "Hello, World!"}
    
    # Process an MCP request
    def process_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        try:
            # Validate request
            if "type" not in request or "parameters" not in request:
                return {"status": "error", "error": "Invalid request format"}
            
            # Get parameters
            parameters = request["parameters"]
            name = parameters.get("name", "World")
            custom_message = parameters.get("message", 
                              self.config.get("default_message", "Hello, World!"))
            
            # Construct response
            message = f"{custom_message} Hello, {name}! This is a response from the {self.name} service."
            return {
                "status": "success",
                "result": message,
                "metadata": {"service": self.name, "version": "1.0.0"}
            }
        except Exception as e:
            logger.error(f"Error: {e}")
            return {"status": "error", "error": str(e)}

# Main entry point
def main():
    config_path = os.environ.get("MCP_CONFIG_PATH", "/var/www/mcp/config/hello_world_config.json")
    service = HelloWorldMCP(config_path)
    
    try:
        request_data = sys.stdin.read()
        logger.info(f"Received request: {request_data[:100]}...")
        
        request = json.loads(request_data)
        response = service.process_request(request)
        
        logger.info(f"Sending response: {json.dumps(response)[:100]}...")
        print(json.dumps(response))
    except Exception as e:
        logger.error(f"Error: {e}")
        print(json.dumps({"status": "error", "error": str(e)}))

if __name__ == "__main__":
    main()
```

### Wrapper Script

```bash
#!/bin/bash
# /var/www/mcp/bin/hello-world

SERVICE_NAME="hello-world-mcp"
LOG_DIR="/var/www/mcp/logs"
LOG_FILE="${LOG_DIR}/${SERVICE_NAME}.log"

mkdir -p "$LOG_DIR"
echo "$(date): Received request for ${SERVICE_NAME}" >> "$LOG_FILE" 2>/dev/null

REQUEST=$(cat)
echo "${REQUEST:0:500}" >> "$LOG_FILE" 2>/dev/null
echo "----------------------------------------" >> "$LOG_FILE" 2>/dev/null

RESPONSE=$(echo "$REQUEST" | python3 /var/www/mcp/services/hello_world_service.py 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "{\"status\": \"error\", \"error\": \"Service implementation failed\"}"
  echo "$(date): Service implementation failed" >> "$LOG_FILE" 2>/dev/null
  exit 1
fi

RESPONSE_LENGTH=${#RESPONSE}
echo "$(date): Returning response (length: $RESPONSE_LENGTH)" >> "$LOG_FILE" 2>/dev/null
echo "$RESPONSE"
```

### Usage

```bash
# Register with Claude
claude mcp add hello-world "/var/www/mcp/bin/hello-world"

# Test the MCP
echo '{"type": "hello_world", "parameters": {"name": "Joni"}}' | /var/www/mcp/bin/hello-world
```

## Best Practices

1. **Keep it Simple**: 
   - Avoid complex dependencies
   - Implement only what you need
   - Use simulation mode for testing

2. **Error Handling**:
   - Validate all inputs
   - Return meaningful error messages
   - Never crash the MCP

3. **Logging**:
   - Log all requests and responses
   - Use consistent log formats
   - Implement log rotation

4. **Configuration**:
   - Use reasonable defaults
   - Make everything configurable
   - Document all configuration options

5. **Permissions**:
   - Ensure log directories are writeable
   - Set executable permissions on wrapper scripts
   - Follow least privilege principle

## Migration from Docker

If you're migrating from a Docker-based MCP architecture:

1. **Extract the Core Logic**: 
   - Copy the essential service code from your Docker implementation
   - Remove Docker-specific dependencies

2. **Simplify Dependencies**:
   - Use only standard libraries when possible
   - Minimize external dependencies

3. **Update Documentation**:
   - Document the transition for team members
   - Update usage instructions

4. **Testing**:
   - Test thoroughly after migration
   - Compare results with Docker version

## Conclusion

This simplified MCP architecture provides a more maintainable, efficient approach to extending Claude Code capabilities without the complexity of Docker. By following the patterns outlined here, you can create reliable MCPs that enhance your development workflow.

---

Document Version: 1.0.0  
Last Updated: 2025-03-27  
Author: Claude  
Repository: https://github.com/jkautto/dai