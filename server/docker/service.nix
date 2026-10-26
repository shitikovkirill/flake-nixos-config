{ config, lib, ... }:

let
  userNames = map (u: u.name) config.services.systemUsers.users;
in
{
  # Docker user, plus "docker" group for every declared user
  users.users = {
    docker = {
      isSystemUser = true;
      group = "docker";
      home = "/home/docker";
      createHome = true;
    };
  } // lib.genAttrs userNames (name: { extraGroups = [ "docker" ]; });

  users.groups.docker = {};

  # Docker service configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    daemon.settings = {
      data-root = "/home/docker/data";
      hosts = [
        "unix:///var/run/docker.sock"
        "tcp://0.0.0.0:2376"
      ];
      # `services.dockerRegistryMirror` is declared in the sibling
      # server/docker-registry module, not here — fall back to `false`
      # instead of an eval error if a host ever imports this module
      # without that one.
      "registry-mirrors" = lib.optional (
        (config.services.dockerRegistryMirror or { }).enable or false
      ) "https://registry.mirror";

      tls = true;
      tlsverify = true;
      tlscacert = "/home/docker/certs/ca.pem";
      tlscert = "/home/docker/certs/server-cert.pem";
      tlskey = "/home/docker/certs/server-key.pem";
    };
  };

  # Create docker data directory
  systemd.tmpfiles.rules = [
    "d /home/docker 0755 docker docker -"
    "d /home/docker/data 0755 docker docker -"
  ];
}
