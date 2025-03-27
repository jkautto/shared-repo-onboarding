# Model Context Protocol (MCP) Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Architecture](#architecture)
3. [Core Concepts](#core-concepts)
   - [Resources](#resources)
   - [Prompts](#prompts)
   - [Tools](#tools)
   - [Transports](#transports)
4. [Debugging](#debugging)
   - [Debugging Guide](#debugging-guide)
   - [MCP Inspector](#mcp-inspector)
5. [Development](#development)
   - [Building MCP with LLMs](#building-mcp-with-llms)
   - [Roadmap](#roadmap)
6. [Examples](#examples)
7. [Clients](#clients)
8. [Claude Code MCP Integration](#claude-code-mcp-integration)
   - [Setting Up MCP Servers](#setting-up-mcp-servers)
   - [MCP Server Scopes](#mcp-server-scopes)
   - [Example: Postgres MCP Server](#example-postgres-mcp-server)
   - [JSON Configuration](#json-configuration)

## Introduction

The Model Context Protocol (MCP) is an open protocol designed to standardize how applications provide context to Large Language Models (LLMs). It serves as "like a USB-C port for AI applications" - providing a standardized way to connect AI models to various data sources and tools.

### Key aspects of MCP include:

**Purpose:**
- Helps build agents and complex workflows on top of LLMs
- Provides pre-built integrations for LLMs
- Offers flexibility in switching between LLM providers
- Ensures best practices for data security

**Architecture:**
MCP follows a client-server model with several key components:
- MCP Hosts: Applications like Claude Desktop that want to access data
- MCP Clients: Protocol clients maintaining connections with servers
- MCP Servers: Lightweight programs exposing specific capabilities
- Local Data Sources: Computer files, databases, services
- Remote Services: External systems accessible via APIs

## Architecture

MCP is a flexible client-server protocol designed to enable seamless communication between LLM applications and integrations.

### Core Components:
- **Protocol Layer**: Handles message framing, request/response linking
- **Transport Layer**: Supports multiple communication mechanisms
  - Stdio transport (local processes)
  - HTTP with Server-Sent Events (remote communication)

### Message Types:
- **Requests**: Expect a response
- **Results**: Successful request responses
- **Errors**: Indicate request failures
- **Notifications**: One-way messages without response expectations

### Connection Lifecycle:
1. **Initialization**: Exchange protocol versions and capabilities
2. **Message Exchange**: Request-response and notification patterns
3. **Termination**: Clean shutdown or error conditions

### Best Practices:
- Validate inputs thoroughly
- Implement proper error handling
- Use type-safe schemas
- Consider transport security
- Monitor and log protocol events

The protocol uses JSON-RPC 2.0 for message exchange and provides a flexible framework for building extensible LLM integrations.

## Core Concepts

### Resources

Resources are a core primitive in MCP that allow servers to expose data and content for LLM interactions.

#### Purpose:
- Represent various types of data like "File contents, database records, API responses, live system data, screenshots and images"
- Identified by unique URIs
- Can contain text or binary data

#### Types of Resources:
1. **Text Resources**:
   - UTF-8 encoded
   - Suitable for source code, configuration files, logs, JSON/XML data

2. **Binary Resources**:
   - Base64 encoded
   - Suitable for images, PDFs, audio/video files

#### Discovery Methods:
1. **Direct Resources**: Servers expose concrete resources via "resources/list" endpoint
2. **Resource Templates**: Servers provide URI templates for dynamic resources

#### Key Features:
- Application-controlled: Clients decide how and when resources are used
- Supports real-time updates
- Clients can subscribe to resource changes

#### Best Practices:
- Use clear, descriptive resource names
- Set appropriate MIME types
- Implement error handling
- Validate URIs
- Consider security implications

### Prompts

MCP Prompts are predefined templates that enable servers to create reusable, user-controlled interaction workflows with LLMs.

#### Core Features:
- Accept dynamic arguments
- Include context from resources
- Chain multiple interactions
- Guide specific workflows
- Surface as UI elements

#### Prompt Structure:
```typescript
{
  name: string;              // Unique identifier
  description?: string;      // Human-readable description
  arguments?: [              // Optional argument list
    {
      name: string;
      description?: string;
      required?: boolean;
    }
  ]
}
```

#### Key Capabilities:
- Discoverable via `prompts/list` endpoint
- Can include embedded resource context
- Support multi-step workflows
- Dynamically generate messages based on input

#### Example Use Cases:
- Generating git commit messages
- Explaining code
- Debugging workflows
- Analyzing project logs and code

#### Best Practices:
- Use clear, descriptive names
- Validate required arguments
- Implement error handling
- Consider prompt composability and security

### Tools

Tools in MCP are a powerful mechanism that enable servers to expose executable functionality to clients, allowing Large Language Models (LLMs) to interact with external systems, perform computations, and take actions.

#### Key Characteristics:
- "Tools are designed to be model-controlled"
- Identified by unique names
- Can include descriptive information
- Represent dynamic operations that can modify state or interact with external systems

#### Tool Definition Structure:
```typescript
{
  name: string;          // Unique identifier
  description?: string;  // Human-readable description
  inputSchema: {         // JSON Schema for parameters
    type: "object",
    properties: { ... }
  }
}
```

#### Example Tool Types:
1. **System Operations**: Interact with local system (e.g., execute shell commands)
2. **API Integrations**: Wrap external APIs (e.g., create GitHub issues)
3. **Data Processing**: Transform or analyze data (e.g., CSV file analysis)

#### Best Practices:
- Provide clear names and descriptions
- Use detailed JSON Schema definitions
- Implement proper error handling
- Include progress reporting
- Keep operations focused and atomic
- Document return value structures
- Implement timeouts
- Consider rate limiting
- Log tool usage

#### Security Considerations:
- Validate input parameters
- Sanitize file paths and commands
- Implement authentication
- Use authorization checks
- Audit tool usage
- Monitor for potential abuse

### Transports

MCP Transports provide the foundation for communication between clients and servers, handling message transmission mechanics.

#### Message Format:
- Uses JSON-RPC 2.0 as the wire format
- Three message types: Requests, Responses, and Notifications

#### Built-in Transport Types:
1. **Standard Input/Output (stdio)**
   - Enables communication through standard input/output streams
   - Useful for local integrations and command-line tools

2. **Server-Sent Events (SSE)**
   - Supports server-to-client streaming
   - Uses HTTP POST requests for client-to-server communication
   - Good for scenarios with restricted networks

#### Custom Transport Features:
- Can implement custom transports for:
  - Specialized network protocols
  - Custom communication channels
  - System integrations
  - Performance optimization

#### Error Handling Considerations:
- Handle connection errors
- Manage message parsing issues
- Address protocol and network timeout problems
- Ensure proper resource cleanup

#### Best Practices:
- Implement proper connection lifecycle management
- Use robust error handling
- Clean up resources
- Validate messages
- Log transport events
- Implement reconnection logic

#### Security Recommendations:
- Implement authentication mechanisms
- Use TLS for network transport
- Validate message integrity
- Set message size limits
- Implement rate limiting

## Debugging

### Debugging Guide

Debugging MCP involves several key tools and approaches:

#### Debugging Tools:
- **MCP Inspector**: "Interactive debugging interface" and "Direct server testing"
- **Claude Desktop Developer Tools**: Provides integration testing, log collection, and Chrome DevTools integration
- **Server Logging**: Enables custom logging, error tracking, and performance monitoring

#### Logging Strategies:
- **Server-side logging**: Log to stderr, which is automatically captured
- Important logging events include:
  - Initialization steps
  - Resource access
  - Tool execution
  - Error conditions
  - Performance metrics

#### Debugging Workflow:
- **Initial Development**:
  - Use Inspector for basic testing
  - Implement core functionality
  - Add logging points
- **Integration Testing**:
  - Test in Claude Desktop
  - Monitor logs
  - Check error handling

#### Best Practices:
- **Structured Logging**:
  - Use consistent formats
  - Include context
  - Add timestamps
  - Track request IDs
- **Error Handling**:
  - Log stack traces
  - Include error context
  - Track error patterns
- **Performance Tracking**:
  - Log operation timing
  - Monitor resource usage
  - Track message sizes
  - Measure latency

#### Security Considerations:
- Sanitize logs
- Protect credentials
- Mask personal information
- Verify permissions
- Monitor access patterns

### MCP Inspector

The MCP Inspector is an interactive developer tool for testing and debugging Model Context Protocol (MCP) servers.

#### Installation and Usage:
- Runs directly through `npx` without installation
- Can inspect servers from NPM, PyPi, or local repositories
- Example command: `npx @modelcontextprotocol/inspector <command>`

#### Main Interface Features:
1. **Server Connection Pane**
   - Select transport for server connection
   - Customize command-line arguments

2. **Resources Tab**
   - List available resources
   - View resource metadata
   - Inspect resource content
   - Test subscriptions

3. **Prompts Tab**
   - Display prompt templates
   - Show prompt arguments
   - Test prompts with custom inputs
   - Preview generated messages

4. **Tools Tab**
   - List available tools
   - Show tool schemas
   - Test tools with custom inputs
   - Display execution results

5. **Notifications Pane**
   - Present server logs
   - Show server notifications

#### Development Workflow Best Practices:
- Start by launching Inspector with server
- Verify connectivity
- Perform iterative testing
- Test edge cases like invalid inputs and concurrent operations

## Development

### Building MCP with LLMs

The guide provides a step-by-step approach to using Large Language Models (specifically Claude) to develop Model Context Protocol (MCP) servers and clients:

#### Preparation Steps:
1. Gather documentation
   - Visit https://modelcontextprotocol.io/llms-full.txt
   - Copy SDK repository README files
   - Paste documentation into Claude conversation

#### Server Description Guidelines:
- Specify resources to expose
- Define tools to provide
- Outline desired prompts
- Describe external system interactions

#### Working with Claude:
- Start with core functionality
- Ask for code explanations
- Request modifications
- Test for edge cases

#### Key MCP Features to Implement:
- Resource management
- Tool definitions
- Prompt templates
- Error handling
- Connection setup

#### Best Practices:
- Break complex servers into smaller components
- Thoroughly test each part
- Prioritize security
- Document code carefully
- Follow MCP specifications

#### Next Steps:
- Carefully review generated code
- Test with MCP Inspector
- Connect to MCP clients
- Iterate based on feedback

### Roadmap

The Model Context Protocol (MCP) Roadmap for H1 2025 focuses on five key areas:

#### 1. Remote MCP Support
- Improve remote server connections
- Add Authentication & Authorization (OAuth 2.0)
- Develop Service Discovery mechanisms
- Explore stateless operation capabilities

#### 2. Reference Implementations
- Create comprehensive client examples
- Develop a streamlined protocol drafting process

#### 3. Distribution & Discovery
- Standardize server packaging
- Simplify server installation
- Implement server sandboxing
- Create a server registry

#### 4. Agent Support
- Enhance hierarchical agent systems
- Improve interactive workflows
- Enable streaming results for long-running operations

#### 5. Broader Ecosystem
- Foster community-led standards development
- Expand support for additional media modalities
- Consider formal standardization

## Examples

The page showcases a comprehensive list of MCP servers categorized into several groups:

### Reference Implementations:
1. **Data and File Systems**
   - Filesystem: Secure file operations
   - PostgreSQL: Read-only database access
   - SQLite: Database interaction
   - Google Drive: File access and search

2. **Development Tools**
   - Git: Repository reading and manipulation
   - GitHub: Repository management
   - GitLab: Project management
   - Sentry: Issue retrieval and analysis

3. **Web and Browser Automation**
   - Brave Search: Web searching
   - Fetch: Web content retrieval
   - Puppeteer: Browser automation

4. **Productivity and Communication**
   - Slack: Channel and messaging tools
   - Google Maps: Location services
   - Memory: Knowledge graph system

5. **AI and Specialized Tools**
   - EverArt: AI image generation
   - Sequential Thinking: Dynamic problem-solving
   - AWS KB Retrieval: Knowledge base interaction

The page also highlights official integrations from companies like Axiom, Cloudflare, E2B, Stripe, and others, as well as community-developed servers for platforms like Docker, Kubernetes, Spotify, and Todoist.

Key installation methods include using `npx` for TypeScript servers and `uvx` or `pip` for Python servers.

## Clients

Complete list of MCP clients:

1. Claude Desktop App
2. Claude Code
3. 5ire
4. BeeAI Framework
5. Cline
6. Continue
7. Cursor
8. Emacs Mcp
9. fast-agent
10. Firebase Genkit
11. GenAIScript
12. Goose
13. LibreChat
14. mcp-agent
15. Microsoft Copilot Studio
16. oterm
17. Roo Code
18. Sourcegraph Cody
19. SpinAI
20. Superinterface
21. TheiaAI/TheiaIDE
22. Windsurf Editor
23. Witsy
24. Zed
25. OpenSumi
26. Daydreams
27. Apify MCP Tester

## Claude Code MCP Integration

Model Context Protocol (MCP) is an open protocol that enables LLMs to access external tools and data sources. For more details, see the MCP documentation.

> **Warning**: Use third party MCP servers at your own risk. Make sure you trust the MCP servers, and be especially careful when using MCP servers that talk to the internet, as these can expose you to prompt injection risk.

### Setting Up MCP Servers

When to use: You want to enhance Claude's capabilities by connecting it to specialized tools and external servers using the Model Context Protocol.

#### 1. Add an MCP Stdio Server

```bash
# Basic syntax
claude mcp add <name> <command> [args...]

# Example: Adding a local server
claude mcp add my-server -e API_KEY=123 -- /path/to/server arg1 arg2
```

#### 2. Manage your MCP servers

```bash
# List all configured servers
claude mcp list

# Get details for a specific server
claude mcp get my-server

# Remove a server
claude mcp remove my-server
```

**Tips:**
- Use the `-s` or `--scope` flag to specify where the configuration is stored:
  - `local` (default): Available only to you in the current project (was called project in older versions)
  - `project`: Shared with everyone in the project via `.mcp.json` file
  - `user`: Available to you across all projects (was called global in older versions)
- Set environment variables with `-e` or `--env` flags (e.g., `-e KEY=value`)
- Configure MCP server startup timeout using the `MCP_TIMEOUT` environment variable (e.g., `MCP_TIMEOUT=10000 claude` sets a 10-second timeout)
- Check MCP server status any time using the `/mcp` command within Claude Code
- MCP follows a client-server architecture where Claude Code (the client) can connect to multiple specialized servers

### MCP Server Scopes

When to use: You want to understand how different MCP scopes work and how to share servers with your team.

#### 1. Local-scoped MCP servers

The default scope (`local`) stores MCP server configurations in your project-specific user settings. These servers are only available to you while working in the current project.

```bash
# Add a local-scoped server (default)
claude mcp add my-private-server /path/to/server

# Explicitly specify local scope
claude mcp add my-private-server -s local /path/to/server
```

#### 2. Project-scoped MCP servers (.mcp.json)

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

#### 3. User-scoped MCP servers

User-scoped servers are available to you across all projects on your machine, and are private to you.

```bash
# Add a user server
claude mcp add my-user-server -s user /path/to/server
```

**Tips:**
- Local-scoped servers take precedence over project-scoped and user-scoped servers with the same name
- Project-scoped servers (in `.mcp.json`) take precedence over user-scoped servers with the same name
- Before using project-scoped servers from `.mcp.json`, Claude Code will prompt you to approve them for security
- The `.mcp.json` file is intended to be checked into version control to share MCP servers with your team
- Project-scoped servers make it easy to ensure everyone on your team has access to the same MCP tools
- If you need to reset your choices for which project-scoped servers are enabled or disabled, use the `claude mcp reset-project-choices` command

### Example: Postgres MCP Server

When to use: You want to give Claude read-only access to a PostgreSQL database for querying and schema inspection.

#### 1. Add the Postgres MCP server

```bash
claude mcp add postgres-server /path/to/postgres-mcp-server --connection-string "postgresql://user:pass@localhost:5432/mydb"
```

#### 2. Query your database with Claude

In your Claude session, you can ask about your database:
```
> describe the schema of our users table
> what are the most recent orders in the system?
> show me the relationship between customers and invoices
```

**Tips:**
- The Postgres MCP server provides read-only access for safety
- Claude can help you explore database structure and run analytical queries
- You can use this to quickly understand database schemas in unfamiliar projects
- Make sure your connection string uses appropriate credentials with minimum required permissions

### JSON Configuration

When to use: You have a JSON configuration for a single MCP server that you want to add to Claude Code.

#### 1. Add an MCP server from JSON

```bash
# Basic syntax
claude mcp add-json <name> '<json>'

# Example: Adding a stdio server with JSON configuration
claude mcp add-json weather-api '{"type":"stdio","command":"/path/to/weather-cli","args":["--api-key","abc123"],"env":{"CACHE_DIR":"/tmp"}}'
```

#### 2. Verify the server was added

```bash
claude mcp get weather-api
```

**Tips:**
- Make sure the JSON is properly escaped in your shell
- The JSON must conform to the MCP server configuration schema
- You can use `-s global` to add the server to your global configuration instead of the project-specific one