{ config, pkgs, lib, ... }:

# Second, standalone registry instance used purely as a pull-through cache
# for Docker Hub (per https://distribution.github.io/distribution/recipes/mirror/).
#
# `services.dockerRegistry` (registry.nix) is a NixOS singleton module — it
# can't be declared twice for a second instance — and a registry configured
# with `proxy.remoteurl` can only be pulled from, not pushed to. So this is
# hand-rolled as its own systemd service/port, reusing the `docker-registry`
# system user/group that registry.nix's module already creates.
let
  cfg = config.services.dockerRegistryMirror;

  port = 5001;
  storagePath = "/home/docker-registry/mirror-data";

  registryConfig = {
    version = "0.1";
    log = {
      level = "info";
      formatter = "json";
      fields.service = "registry-mirror";
    };
    storage = {
      cache.blobdescriptor = "inmemory";
      filesystem.rootdirectory = storagePath;
      # Pull-through caches manage their own blob lifetime (proxy.ttl below);
      # running delete/gc against them is not supported upstream.
      delete.enabled = false;
    };
    http = {
      addr = "0.0.0.0:${builtins.toString port}";
      headers."X-Content-Type-Options" = [ "nosniff" ];
    };
    health.storagedriver = {
      enabled = true;
      interval = "10s";
      threshold = 3;
    };
    proxy = {
      remoteurl = "https://registry-1.docker.io";
      ttl = "168h";
    };
  };

  configFile = pkgs.writeText "docker-registry-mirror-config.yml" (builtins.toJSON registryConfig);
in
{
  options.services.dockerRegistryMirror.enable = lib.mkEnableOption "the Docker Hub pull-through cache registry";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.dockerRegistry.enable;
        message = ''
          services.dockerRegistryMirror requires services.dockerRegistry.enable = true:
          it reuses the "docker-registry" system user/group and the registry package
          that module creates, rather than provisioning its own.
        '';
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${storagePath} 0750 docker-registry docker-registry -"
    ];

    systemd.services.docker-registry-mirror = {
      description = "Docker Registry pull-through cache for Docker Hub";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      script = ''
        ${config.services.dockerRegistry.package}/bin/registry serve ${configFile}
      '';
      serviceConfig = {
        User = "docker-registry";
        Group = "docker-registry";
        WorkingDirectory = storagePath;
        MemoryMax = "512M";
        MemoryHigh = "400M";
        CPUQuota = "200%";
        IOWeight = 500;
      };
    };

    # Health check service, mirroring registry.nix's pattern for the push registry.
    systemd.services.docker-registry-mirror-health = {
      description = "Docker Registry mirror health check";
      after = [ "docker-registry-mirror.service" ];
      wants = [ "docker-registry-mirror.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.curl}/bin/curl -f http://localhost:${builtins.toString port}/v2/";
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStartSec = "5s";
      };
    };
  };
}
