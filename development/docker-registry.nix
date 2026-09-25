{ config, pkgs, ... }:

{
  # Встроенный Docker Registry (Native NixOS)
  # Note: The dockerRegistry module automatically creates a 'docker-registry'
  # system user and uses it to run the service, so we don't need to declare it
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    listenAddress = "127.0.0.1";
    storagePath = "/home/docker-registry/data";

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
      serverName = "registry.home";
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000";
        extraConfig = ''
          client_max_body_size 512m;
          proxy_set_header Host $http_host;
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
