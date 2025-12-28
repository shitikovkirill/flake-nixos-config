{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Исправление ошибки: для карт до архитектуры Turing (как у ASUS N56vj)
    # необходимо использовать закрытые модули ядра.
    open = false;

    # Рекомендуется также включить режим управления питанием, 
    # так как это ноутбук.
    powerManagement.enable = true;
    
    # Для старых карт может потребоваться указать конкретную версию драйвера (legacy),
    # если стандартная версия (production) перестанет поддерживать ваше устройство [2].
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470; 
  };
}