{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ python3 ];

  programs.zsh = { ohMyZsh = { plugins = [ "python" "django" ]; }; };

  environment.shellAliases = {
    py-clean =
      "find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -exec rm -rf {} \\;";
    ppath = ''python -c "import sys; print('\n'.join(sys.path))"'';
  };
}
