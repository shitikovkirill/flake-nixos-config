{ config, pkgs, ... }:

{
  imports = [
    ./claude.nix
    ./mcp.nix
    #./openai.nix
    #./local-llm.nix
    #./code-assistants.nix
    #./utils.nix
  ];
}
