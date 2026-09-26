{ config, pkgs, ... }:

{
  # Periodic Docker cleanup tasks
  systemd.services.docker-cleanup-cache = {
    description = "Clean Docker build cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker builder prune -af";
      User = "root";
    };
  };

  systemd.services.docker-cleanup-images = {
    description = "Clean Docker dangling images";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker image prune -af";
      User = "root";
    };
  };

  systemd.services.docker-cleanup-volumes = {
    description = "Clean Docker dangling volumes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker volume prune -af";
      User = "root";
    };
  };

  systemd.timers.docker-cleanup-cache = {
    description = "Run Docker build cache cleanup weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 02:00:00";
      Persistent = true;
    };
    unitConfig.After = "docker.service";
  };

  systemd.timers.docker-cleanup-images = {
    description = "Run Docker image cleanup daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
    unitConfig.After = "docker.service";
  };

  systemd.timers.docker-cleanup-volumes = {
    description = "Run Docker volume cleanup weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 02:30:00";
      Persistent = true;
    };
    unitConfig.After = "docker.service";
  };

  # Shell aliases for cleanup tasks
  environment.shellAliases = {
    # Container management
    drmc = "docker rm $(docker ps -a -q)";
    drimage = "docker rmi $(docker images -q)";
    drdimage = "docker rmi $(docker images --filter 'dangling=true' -q --no-trunc)";
    drvolume = "docker volume rm $(docker volume ls -q --filter dangling=true)";
    drnetwork = "docker network prune";
    dclearall = "docker system prune -a -f";
    dstopc = "docker stop $(docker ps -aq)";
    dstopc_with_restart_always = "docker stop $(docker ps -a -q) & docker update --restart=no $(docker ps -a -q) & systemctl restart docker";
    dnorestart = "docker update --restart=no $(docker ps -aq)";

    # Cleanup task control
    dclean-cache = "sudo systemctl start docker-cleanup-cache";
    dclean-images = "sudo systemctl start docker-cleanup-images";
    dclean-volumes = "sudo systemctl start docker-cleanup-volumes";
    dclean-all = "sudo systemctl start docker-cleanup-cache docker-cleanup-images docker-cleanup-volumes";
    dclean-status = "systemctl status docker-cleanup-cache docker-cleanup-images docker-cleanup-volumes";
  };
}
