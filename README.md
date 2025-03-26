# Shared Tools Access

**IMPORTANT: This repository contains ONLY the access instructions.**

The actual shared tools are in the private repository at https://github.com/jkautto/kaut-shared.

## Quick Start (TL;DR)

Run this to get immediate access (requires git and curl):

```bash
# Replace YOUR_TOKEN with your GitHub token
git clone https://github.com/jkautto/shared-repo-onboarding.git
cd shared-repo-onboarding
chmod +x init_access.sh
./init_access.sh YOUR_TOKEN
```

## What Is This?

This repository contains ONLY the initialization script to access the shared tools. The actual tools repository is https://github.com/jkautto/kaut-shared (private).

## Step by Step Instructions

1. **Request a token** from your system administrator with access to the jkautto/kaut-shared repository

2. **Clone this repository**:
   ```bash
   git clone https://github.com/jkautto/shared-repo-onboarding.git
   cd shared-repo-onboarding
   ```

3. **Make the script executable**:
   ```bash
   chmod +x init_access.sh
   ```

4. **Run the script with your token**:
   ```bash
   ./init_access.sh YOUR_TOKEN
   ```
   This will:
   - Verify your token has access to the private repository
   - Clone the private repository to ./kaut-shared-tools
   - Display next steps

5. **Follow the setup instructions** in the cloned repository

## If the Script Doesn't Work

If you're having trouble with the initialization script, you can directly clone the repository:

```bash
# Replace YOUR_TOKEN with your GitHub token
git clone https://YOUR_TOKEN@github.com/jkautto/kaut-shared.git kaut-shared-tools
```

## What's in the Private Repository?

The private repository (jkautto/kaut-shared) contains:

- Context management tools (/pc, /ac, /hk) for preserving work across sessions
- Shared utilities for system maintenance
- Documentation templates and guidelines
- Reference implementations
- Shared MCP server configurations

## Need Help?

Contact your system administrator if you encounter issues.