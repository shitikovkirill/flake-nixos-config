{ config, ... }:

{
  # Docker user
  users.users.docker = {
    isSystemUser = true;
    group = "docker";
    home = "/home/docker";
    createHome = true;
  };

  users.groups.docker = {};

  # Docker service configuration
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    daemon.settings = {
      data-root = "/home/docker/data";
      hosts = [
        "unix:///var/run/docker.sock"
        "tcp://0.0.0.0:2375"
      ];
    };
  };

  # Create docker data directory
  systemd.tmpfiles.rules = [
    "d /home/docker 0755 docker docker -"
    "d /home/docker/data 0755 docker docker -"
  ];

  # Add user to docker group
  users.users.kirill.extraGroups = [ "docker" ];
}
