{
  programs.bash.shellAliases = {
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    check_calendar = "systemd-analyze calendar";
    file_size = "du --apparent-size --block-size=1 -h ";
    folder_size = "du -h --max-depth=1 | sort -hr";
  };
}
