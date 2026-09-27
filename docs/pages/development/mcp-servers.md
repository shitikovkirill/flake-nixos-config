# MCP Servers Configuration

`development/ai/mcp/default.nix` configures MCP (Model Context Protocol)
servers for Claude Code. MCP servers extend Claude's capabilities by
providing access to external tools, APIs, and services.

## Current Setup

All servers below are defined in a single `mcpServers` attribute set in
`development/ai/mcp/default.nix` and are **all active unconditionally** —
there's no per-server enable/disable flag. The corresponding packages are
installed via `environment.systemPackages`, and the merged config is
written to `~/.config/mcp/config.json` for every user declared in
`services.systemUsers.users` (see [Architecture](../architecture.md)).

### Core

**memory** - `mcp-server-memory`
- Persistent memory across conversations
- Stores context, facts, and user preferences
- **Use when**: You need Claude to remember information between sessions
- **Best with**: Any other server, especially for long-term projects

**time** - `mcp-server-time`
- Current time and date information, timezone conversions, date calculations
- **Use when**: Working with scheduling, timestamps, or time-sensitive tasks

### Language Servers

**language-server** - `mcp-language-server` (wired to `pyright`)
- Python language server integration: type checking and code analysis
- **Use when**: Writing or analyzing Python code
- **Best with**: memory (to track project structure)

### Web

**fetch** - `mcp-server-fetch`
- HTTP requests, API calls, web scraping
- **Use when**: Fetching data from APIs or websites
- **Best with**: memory (to cache results)
- Overlaps with playwright for simple HTTP tasks — pick one per use case

**playwright** - `playwright-mcp`
- Browser automation, complex web interactions, screenshot capture
- **Use when**: Testing web UIs or scraping JavaScript-heavy sites
- **Warning**: Resource-intensive (launches full browser instances)

### DevOps

**nixos** - `mcp-nixos`
- NixOS/nixpkgs/home-manager package and option search

**k8s** - `mcp-k8s-go`
- Kubernetes cluster management and resource inspection
- Network-heavy, cluster communication

### AI

**sequential-thinking** - `mcp-server-sequential-thinking`
- Extended step-by-step reasoning for complex logical problems
- Increases response time significantly (2-5x) — most useful for problems
  that genuinely need it, not routine tasks

### Utilities

**markitdown** - `markitdown-mcp`
- Converts Office docs, PDFs, HTML, etc. to Markdown

## Recommended Combinations

| Use case | Servers |
|----------|---------|
| Software development | memory + time + language-server |
| Web dev/testing | memory + time + playwright, or memory + fetch for lightweight API work |
| DevOps work | memory + time + nixos + k8s |
| Research & analysis | memory + time + fetch + sequential-thinking |
| Documentation work | memory + markitdown |

## Performance Considerations

Resource impact, high to low: **playwright** (full browser) > **k8s**
(network-heavy) > **sequential-thinking** (2-5x reasoning time) >
**language-server** (background analysis) > memory/time/fetch/nixos/markitdown
(minimal).

Since everything here is always-on, the practical lever is which packages
you keep in the `mcpServers`/`environment.systemPackages` lists in
`development/ai/mcp/default.nix` — see below.

## Adding or Removing a Server

There's no `disabled` flag to flip — edit
`development/ai/mcp/default.nix` directly:

1. Remove (or comment out) the server's entry in the `mcpServers`
   attribute set.
2. Remove the matching package from `environment.systemPackages` in the
   same file.
3. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#asus-n56vj-desktop
   # or .#asus-n56vj-server
   ```

`~/.config/mcp/config.json` is regenerated from `mcpServers` on every
rebuild — manual edits to that file are overwritten.

### Server arguments

Some servers accept extra CLI arguments, e.g. `language-server`:

```nix
"language-server" = {
  command = "${pkgs.mcp-language-server}/bin/mcp-language-server";
  args = [ "--lsp" "${pkgs.pyright}/bin/pyright-langserver" "--workspace" "\${LSP_WORKSPACE}" "--" "--stdio" ];
};
```

## Troubleshooting

### Server not loading
1. Check `~/.config/mcp/config.json` — confirm the server is listed.
2. Verify the package is installed: `which <server-binary>`.
3. Check Claude's debug logs: `~/.claude/debug/`.

### Slow responses
1. Consider dropping `sequential-thinking` if it's not needed for the task.
2. Consider dropping `playwright` if browser automation isn't in use.
3. Check whether multiple heavy servers (playwright, k8s,
   sequential-thinking) are all wired in at once.

## References

- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
