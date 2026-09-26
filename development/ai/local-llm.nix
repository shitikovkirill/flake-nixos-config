{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ollama # Run local models (Llama, Mistral, etc.)
    lmstudio # GUI for local models
  ];
}
