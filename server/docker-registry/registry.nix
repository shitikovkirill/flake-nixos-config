{ config, pkgs, ... }:

{
  # Built-in Docker Registry
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    storagePath = "/home/docker-registry/data";

    extraConfig = {
      http = {
        addr = "0.0.0.0:5000";
      };

      delete.enabled = true;
      storage.redirect.disable = false;

      # Health check configuration
      health = {
        storagedriver.enabled = true;
      };

      # Logging configuration
      log = {
        level = "info";
        formatter = "json";
      };
    };
  };

  # Add health check service
  systemd.services.docker-registry-health = {
    description = "Docker Registry health check";
    after = [ "docker-registry.service" ];
    wants = [ "docker-registry.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.curl}/bin/curl -f http://localhost:5000/v2/ || exit 1";
      Restart = "on-failure";
      RestartSec = "10s";
      TimeoutStartSec = "5s";
    };
  };

  # Resource limits for registry
  systemd.services.docker-registry.serviceConfig = {
    MemoryMax = "512M";
    MemoryHigh = "400M";
    CPUQuota = "200%";
    IOWeight = 500;
  };
}
