{
  programs.bash.shellAliases = {
    clear_nixp =
      "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-collect-garbage -d && sudo nix-collect-garbage -d";
    nixp =
      "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq";
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    check_calendar = "systemd-analyze calendar";
  };
}
