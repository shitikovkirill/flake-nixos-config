{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    powerManagement.enable = true;

    # Для старых карт может потребоваться указать конкретную версию драйвера (legacy),
    # если стандартная версия (production) перестанет поддерживать ваше устройство [2].
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470; 
  };
}
