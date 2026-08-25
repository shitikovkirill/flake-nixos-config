{ config, pkgs, ... }:
let
  PROMPTS = "~/Code/git.webwave.work/GenerativeAI/prompts";
  DEBUG_PROMPTS = "~/Code/git.webwave.work/VSCode/mcp-debug-bridge";
in
{
  environment.systemPackages = with pkgs; [
    claude-code
    claude-monitor
  ];

  programs.bash.shellAliases = {
    claude = "claude --plugin-dir ${PROMPTS} --plugin-dir ${DEBUG_PROMPTS} --mcp-config ~/.config/mcp/config.json";
  };
}
