{ config, pkgs, ... }:

{
  # Встроенный Docker Registry (Native NixOS)
  # Note: The dockerRegistry module automatically creates a 'docker-registry'
  # system user and uses it to run the service, so we don't need to declare it
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    listenAddress = "0.0.0.0";
    storagePath = "/home/docker-registry/data";

    extraConfig = {
      delete.enabled = true;
      storage.redirect.disable = false;
    };
  };

  # Открыть порт в файрволе
  networking.firewall.allowedTCPPorts = [
    5000  # Docker Registry API
  ];

  # Добавить запись в /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
  };
}
