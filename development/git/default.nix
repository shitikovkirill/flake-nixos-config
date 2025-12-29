{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gitg git git-crypt pre-commit ];

  home-manager.users.kirill = {
    home = { file.".gitignore".source = ./gitignore; };

    programs.git = {
      enable = true;
      settings = {
        user = {
          email = "shitikovkirillt@gmail.com";
          name = "Shitikov Kirill";
        };
        alias = {
          ct = "checkout";
          br = "branch";
          co = "commit";
          st = "status";
          hist =
            "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
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
