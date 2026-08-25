let 
  PROMPTS="~/Code/git.webwave.work/GenerativeAI/prompts";
  DEBUG_PROMPTS="~/Code/git.webwave.work/VSCode/mcp-debug-bridge";
in {
  programs.bash.shellAliases = {
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    check_calendar = "systemd-analyze calendar";
    claude="claude --plugin-dir ${PROMPTS} --plugin-dir ${DEBUG_PROMPTS}";
  };
}
