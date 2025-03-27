# Simple Hello World MCP

A minimal Model Capability Provider (MCP) for testing Claude Code integration.

## Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Run the MCP server
python app.py
```

The server will be available at http://localhost:3500

## Endpoints

- `/` - Basic service information
- `/health` - Health check
- `/process` - Process a request

## Usage with Claude Code

Register this MCP with Claude Code:

```bash
claude mcp add --url http://localhost:3500 --name "Hello World MCP"
```

Then use it in a conversation:

```
<function_calls>
<invoke name="HelloWorldMCP">
<parameter name="query">How are you today?</parameter>
</invoke>
</function_calls>
```