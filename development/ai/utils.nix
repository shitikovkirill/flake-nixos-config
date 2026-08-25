{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fabric-ai           # AI фреймворк с паттернами промптов
    llm                 # CLI для взаимодействия с LLM
    gpt4all             # Локальный чат с открытыми моделями
  ];
}
