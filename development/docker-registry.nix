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
    80    # HTTP для nginx
  ];

  # Nginx reverse proxy для Docker Registry
  services.nginx = {
    enable = true;
    virtualHosts."registry.home" = {
      listen = [
        { addr = "0.0.0.0"; port = 80; }
        { addr = "[::]"; port = 80; }
      ];

      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };
  };

  # Добавить запись в /etc/hosts
  networking.hosts = {
    "127.0.0.1" = [ "registry.home" ];
    "::1" = [ "registry.home" ];
  };
}
