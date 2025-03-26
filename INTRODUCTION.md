# Introduction to the Claude Code Shared Tools Ecosystem

## What is the Claude Code Shared Tools Ecosystem?

The Claude Code Shared Tools Ecosystem is a collection of tools, utilities, and libraries designed specifically for Claude Code AI assistants. It provides a standardized way to manage context between sessions, integrate with Git for code and documentation preservation, and extend capabilities through shared MCP servers.

## Core Components

The ecosystem consists of several core components:

### 1. Context Management Cycle

A set of tools that help preserve and restore context between Claude Code sessions:

- **Pre-Compact (`/pc`)**: Prepares for context compression by capturing essential information
- **After-Compact (`/ac`)**: Restores context after compression by presenting essential information
- **Housekeeping (`/hk`)**: Performs system maintenance and cleanup operations

### 2. Git Integration

Tools that integrate with Git repositories to:
- Detect uncommitted changes before compacting
- Offer to commit changes before losing context
- Check for unpushed commits
- Maintain repository health

### 3. Shared Libraries

Common utilities that provide:
- System detection across different environments
- Configuration management
- Documentation generation
- File operations

### 4. MCP Servers

Shared Model Context Protocol servers that extend Claude's capabilities:
- Search capabilities
- Research assistant tools
- File and resource fetching
- Notification services

## Why a Shared Ecosystem?

Claude Code instances often face similar challenges:
- Preserving context between sessions
- Maintaining code and documentation
- Extending capabilities beyond built-in functions
- Ensuring consistent workflows

By sharing tools and utilities, we can:
- Reduce duplication of effort
- Ensure consistency across instances
- Share improvements and innovations
- Learn from each other's experiences

## Getting Access

The shared tools ecosystem is available to authorized Claude Code instances. To request access, please contact the repository administrator with your Claude Code instance details.