{ config, pkgs, ... }:

let
  cfg = config.custom.devServerConfig;
  user = cfg.user;
in {
  environment.systemPackages = with pkgs; [ git git-crypt pre-commit ];

  # NOTE: original recipe used the flat programs.git.{userName,userEmail,
  # extraConfig,aliases} options. Current home-manager expects the ini-style
  # `settings` attribute set instead (mirrors this repo's development/git
  # module, which already relies on `settings` and is known to work).
  home-manager.users.${user} = {
    home = { file.".gitignore".source = ./gitignore.txt; };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Shitikov Kirill";
          email = "shitikovkirillt@gmail.com";
        };
        push = { default = "current"; };
        apply = { whitespace = "nowarn"; };
        core = {
          autocrlf = "input";
          excludesfile = "~/.gitignore";
          editor = "nano";
        };
        credential = { helper = "cache --timeout=3600"; };
        pull = { rebase = false; };
        color = { ui = true; };
        url = {
          "ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
          "ssh://git@gitlab.com/" = { insteadOf = "https://gitlab.com/"; };
          "ssh://gitea@git.webwave.work/" = {
            insteadOf = "https://git.webwave.work/";
          };
        };
        alias = {
          ct = "checkout";
          br = "branch";
          co = "commit";
          st = "status";
          hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
          fhist = "log --follow -p --";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          target = "log --oneline --decorate";
          gitg = "!gitg";
          cleanup =
            "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
          sdiff = "!git diff && git submodule foreach 'git diff'";
          spush = "push --recurse-submodules=on-demand";
          supdate = "submodule update --remote --merge";
        };
      };
    };
  };

  programs.zsh = { ohMyZsh = { plugins = [ "git" "gitignore" ]; }; };

  environment.shellAliases = {
    git-show-local-merged-b =
      "git branch --merged | grep -v master | grep -v develop";
    git-show-remote-merged-b =
      "git branch -r --merged | grep -v master | grep -v develop";

    git-remove-local-merged-b =
      "git branch --merged | grep -v master | grep -v develop | xargs git branch -d";

    git-fix-conflict =
      "git diff --name-only --diff-filter=U | uniq  | xargs $EDITOR";
  };
}
