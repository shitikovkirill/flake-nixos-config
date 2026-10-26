{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fabric-ai # AI framework with prompt patterns
    llm # CLI for interacting with LLM
    gpt4all # Local chat with open models
  ];
}
