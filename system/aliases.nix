{
  programs.bash.shellAliases = {
    clear_trash = "sudo rm -rf $HOME/.local/share/Trash";
    clear_dns = "sudo nscd -i hosts";
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    check_calendar = "systemd-analyze calendar";
    file_size = "du --apparent-size --block-size=1 -h ";
    folder_size = "du -h --max-depth=1 | sort -hr";
  };
}
