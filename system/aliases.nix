{
  programs.bash.shellAliases = {
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    check_calendar = "systemd-analyze calendar";
  };
}
