{ config, pkgs, ... }:

{
  imports = [
    ./claude.nix
    ./mcp
    #./openai.nix
    #./local-llm.nix
    #./code-assistants.nix
    #./utils.nix
  ];
}
