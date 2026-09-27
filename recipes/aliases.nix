{
  environment.shellAliases = {
    clear_nixp =
      "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old && nix-collect-garbage -d && sudo nix-collect-garbage -d";
    clear_dns = "sudo nscd -i hosts";
    fix_own = "sudo chown -R $(id -un):$(id -gn)";
    find_from_current_folder = "grep -rni $(pwd) -e ";
    file_size = "du --apparent-size --block-size=1 -h ";
    folder_size = "du -h --max-depth=1 | sort -hr";
  };
}
