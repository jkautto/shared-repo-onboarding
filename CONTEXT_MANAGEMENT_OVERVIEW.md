# Context Management Overview

One of the most powerful features of the Claude Code Shared Tools Ecosystem is the context management cycle, which helps preserve and restore context when using Claude Code's `/compact` command.

## The Context Management Challenge

Claude Code has a `/compact` command that compresses conversation history to reduce token usage. While this is valuable for managing token limits, it can lead to loss of important context.

The context management cycle addresses this challenge with a three-phase process:

## Phase 1: Pre-Compact (`/pc`)

Run the `/pc` command before using `/compact` to:

- Analyze current work and dependencies
- Check Git status and offer to commit changes
- Update the HANDOVER.md document with recent work
- Extract key information for later restoration
- Prompt for reflection on North Star alignment

Example:
```bash
/pc
```

## Phase 2: Compact

Use Claude Code's built-in `/compact` command to compress conversation history and reduce token usage.

Example:
```bash
/compact
```

## Phase 3: After-Compact (`/ac`)

Run the `/ac` command after using `/compact` to:

- Display the North Star vision from ROADMAP.md
- Present key details from the HANDOVER.md document
- Show Git status and recent changes
- Highlight pending tasks and next steps
- Provide a clear picture of where you left off

Example:
```bash
/ac
```

## Benefits of the Context Management Cycle

This three-phase approach provides several benefits:

1. **Reduced Token Usage**: Compact conversations without losing important context
2. **Maintained Productivity**: Quickly resume work where you left off
3. **Git Integration**: Ensure code and documentation changes are preserved
4. **Work Continuity**: Maintain momentum across session boundaries
5. **Strategic Alignment**: Regular reminders of North Star vision

## Getting Access

The context management tools are available in the private shared repository. To request access, please contact the repository administrator.