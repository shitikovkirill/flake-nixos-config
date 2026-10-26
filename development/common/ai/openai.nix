{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aichat # CLI chat with multiple LLMs (OpenAI, Claude, Gemini, etc.)
    shell-gpt # ChatGPT in terminal
  ];
}
