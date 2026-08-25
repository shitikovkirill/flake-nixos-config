{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aichat              # CLI чат с множеством LLM (OpenAI, Claude, Gemini и др.)
    shell-gpt           # ChatGPT в терминале
  ];
}
