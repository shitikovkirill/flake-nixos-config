{ config, pkgs, ... }:

{
  # Встроенный Docker Registry (Native NixOS)
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    listenAddress = "0.0.0.0";
    storagePath = "/var/lib/docker-registry";

    extraConfig = {
      delete.enabled = true;
      storage.redirect.disable = false;
    };
  };

  # Открыть порт в файрволе
  networking.firewall.allowedTCPPorts = [
    5000  # Docker Registry
  ];
}
