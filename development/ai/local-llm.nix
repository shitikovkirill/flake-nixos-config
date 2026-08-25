{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ollama              # Запуск локальных моделей (Llama, Mistral, и др.)
    lmstudio            # GUI для локальных моделей
  ];
}
