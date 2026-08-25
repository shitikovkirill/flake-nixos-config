# MCP Servers Configuration

This directory contains MCP (Model Context Protocol) server configurations for Claude Code, organized by functional categories.

## Overview

MCP servers extend Claude's capabilities by providing access to external tools, APIs, and services. This configuration automatically manages server installation and Claude integration.

## Currently Configured Servers

### Core Servers (Always Active)

**memory** - `mcp-server-memory`
- Persistent memory across conversations
- Stores context, facts, and user preferences
- Automatically recalls relevant information
- **Use when**: You need Claude to remember information between sessions
- **Best with**: Any other server, especially for long-term projects

**time** - `mcp-server-time`
- Current time and date information
- Timezone conversions
- Date calculations
- **Use when**: Working with scheduling, timestamps, or time-sensitive tasks
- **Best with**: Any server requiring temporal context

**language-server** - `mcp-language-server` (with pyright)
- Python language server integration
- Type checking and code analysis
- **Use when**: Writing or analyzing Python code
- **Best with**: memory (to track project structure)

### Web Servers (Disabled by Default)

**fetch** - `mcp-server-fetch`
- HTTP requests and API calls
- Web scraping
- **Use when**: Fetching data from APIs or websites
- **Best with**: memory (to cache results), time (for rate limiting)
- **Conflicts**: May overlap with playwright for simple web tasks

**playwright** - `playwright-mcp`
- Browser automation
- Complex web interactions
- Screenshot capture
- **Use when**: Testing web UIs or scraping JavaScript-heavy sites
- **Best with**: memory (to store session data)
- **Warning**: Resource-intensive, disable when not needed

### DevOps Servers (Disabled by Default)

**nixos** - `mcp-nixos`
- NixOS package search and information
- Configuration helpers
- **Use when**: Managing NixOS configurations
- **Best with**: devops servers for infrastructure work
- **Note**: Disabled by default

**k8s** - `mcp-k8s-go`
- Kubernetes cluster management
- Resource inspection
- **Use when**: Managing Kubernetes deployments
- **Best with**: nixos (for declarative configs), memory (cluster state)
- **Conflicts**: None, but resource-heavy

### AI Servers (Disabled by Default)

**sequential-thinking** - `mcp-server-sequential-thinking`
- Extended reasoning capabilities
- Step-by-step problem solving
- **Use when**: Complex logical problems or mathematical proofs
- **Best with**: memory (to track reasoning chains)
- **Note**: Increases response time significantly

### Utility Servers (Disabled by Default)

**markitdown** - `markitdown-mcp`
- Convert various formats to Markdown
- Document processing
- **Use when**: Converting Office docs, PDFs, HTML to Markdown
- **Best with**: memory (to store conversion patterns)

## Recommended Server Combinations

### For Software Development
```
✓ memory + time + language-server
```
Provides persistent context, temporal awareness, and Python tooling.

### For Web Development/Testing
```
✓ memory + time + playwright
✓ memory + fetch (for API work)
```
Playwright for full browser automation, or fetch for lightweight API testing.

### For DevOps Work
```
✓ memory + time + nixos + k8s
```
Complete infrastructure management with NixOS and Kubernetes support.

### For Research & Analysis
```
✓ memory + time + fetch + sequential-thinking
```
Data fetching with enhanced reasoning capabilities.

### For Documentation Work
```
✓ memory + markitdown
```
Document conversion with context retention.

## Conflict Matrix

| Server | Conflicts With | Reason |
|--------|---------------|---------|
| fetch | playwright | Overlapping functionality for simple HTTP requests |
| sequential-thinking | (none) | Can be used with any, but slows all responses |
| playwright | (none) | Resource-heavy but no direct conflicts |

## Performance Considerations

### Resource Impact (High to Low)
1. **playwright** - Launches full browser instances
2. **k8s** - Network-heavy, cluster communication
3. **sequential-thinking** - Increases reasoning time 2-5x
4. **language-server** - Background analysis processes
5. **fetch**, **memory**, **time**, **nixos**, **markitdown** - Minimal impact

### Recommendations
- **Disable** `playwright` when not doing browser automation
- **Disable** `sequential-thinking` for routine tasks
- **Enable** `fetch` only when working with APIs
- **Keep enabled**: memory, time (minimal overhead, high value)

## Enabling/Disabling Servers

### Method 1: Edit Configuration Files

Edit the appropriate category file in `development/ai/mcp/`:

```nix
mcpServers = {
  server-name = {
    command = "...";
    disabled = true;  # Set to false or remove to enable
  };
};
```

### Method 2: Override in default.nix

For temporary changes, you can override in `default.nix` without editing category files.

### Apply Changes

```bash
sudo nixos-rebuild switch --flake .
```

The `~/.claude/.mcp.json` file will be automatically updated.

## Server Status Quick Reference

| Server | Status | Category | Resource Impact |
|--------|--------|----------|-----------------|
| memory | ✓ Active | core | Low |
| time | ✓ Active | core | Low |
| language-server | ✓ Active | language | Medium |
| fetch | ✗ Disabled | web | Low |
| playwright | ✗ Disabled | web | High |
| nixos | ✗ Disabled | devops | Low |
| k8s | ✗ Disabled | devops | High |
| sequential-thinking | ✗ Disabled | ai | High |
| markitdown | ✗ Disabled | utils | Low |

## Best Practices

### 1. Start Minimal
Enable only the servers you actively need. More servers = more overhead.

### 2. Use Memory Server
Always keep `memory` enabled for consistent context across sessions.

### 3. Enable on Demand
For resource-heavy servers (playwright, k8s, sequential-thinking):
- Enable only when starting relevant work
- Disable when finished
- Rebuild configuration to apply changes

### 4. Monitor Performance
If Claude responses slow down:
1. Check which servers are active
2. Disable heavy servers (playwright, sequential-thinking)
3. Rebuild and test

### 5. Workspace-Specific Configs
Consider creating different MCP profiles for different types of work:
- Development: memory + time + language-server
- DevOps: memory + time + nixos + k8s
- Research: memory + time + fetch + sequential-thinking

## Troubleshooting

### Server Not Loading
1. Check `~/.claude/.mcp.json` - ensure server is listed and not disabled
2. Verify package is installed: `which <server-binary>`
3. Check Claude logs: `~/.claude/debug/`

### Slow Responses
1. Disable `sequential-thinking` if enabled
2. Disable `playwright` if not needed
3. Check if multiple heavy servers are running simultaneously

### Server Conflicts
1. If fetch and playwright both enabled, choose one based on need:
   - Simple API calls → fetch
   - Browser automation → playwright
2. Disable unused server and rebuild

## Adding New Servers

See [CLAUDE.md](./CLAUDE.md) for detailed instructions on adding and organizing new MCP servers.

## Technical Details

### Configuration Structure
```
mcp/
├── default.nix              # Merges all configurations
├── core.nix                 # Essential servers
├── web.nix                  # Web interaction
├── devops.nix               # Infrastructure
├── ai.nix                   # AI enhancement
├── utils.nix                # Utilities
├── language-servers.nix     # Language tooling
└── README.md                # This file
```

### Auto-Generated Config
The configuration automatically generates `~/.claude/.mcp.json` with all active servers. Manual edits to this file will be overwritten on next rebuild.

### Server Arguments
Some servers accept additional arguments. Example:

```nix
mcpServers = {
  server-name = {
    command = "${pkgs.server}/bin/server";
    args = [
      "--flag"
      "value"
    ];
  };
};
```

## References

- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)

## Contributing

When adding new servers:
1. Choose appropriate category file
2. Add package and configuration
3. Set `disabled = true` for resource-heavy or experimental servers
4. Update this README with server description and recommendations
5. Test server combinations for conflicts
