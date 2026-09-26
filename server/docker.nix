{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    lazydocker
    #arion
    #ctop
    #docker-machine

    #minikube
    kubectl
    #kubernetes-helm
  ];

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

  users.users.kirill.extraGroups = [ "docker" ];

  networking.firewall.allowedTCPPorts = [
    2375  # Docker remote API
  ];

  programs.zsh = {
    ohMyZsh = {
      plugins = [
        "docker"
        "docker-compose"
      ];
    };
  };

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

  systemd.services.docker-cleanup-volumes = {
    description = "Clean Docker dangling volumes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker volume prune -af";
      User = "root";
    };
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

  environment.shellAliases = {
    drmc = "docker rm $(docker ps -a -q)";
    drimage = "docker rmi $(docker images -q)";
    drdimage = "docker rmi $(docker images --filter 'dangling=true' -q --no-trunc)";
    drvolume = "docker volume rm $(docker volume ls -q --filter dangling=true)";
    drnetwork = "docker network prune";
    dclearall = "docker system prune -a -f";
    dstopc = "docker stop $(docker ps -aq)";
    dstopc_with_restart_always = "docker stop $(docker ps -a -q) & docker update --restart=no $(docker ps -a -q) & systemctl restart docker";
    dnorestart = "docker update --restart=no $(docker ps -aq)";
    dhist = "docker history --no-trunc";
    dlint = ''
      docker run --rm -i hadolint/hadol  environment.systemPackages = with pkgs; [
          python3
        ];int'';
    dlint-deb = "docker run -v $(pwd):/app:ro --workdir=/app --rm -i hadolint/hadolint:latest-debian hadolint";
    dpoetry = "docker run -v $(pwd):/app --workdir=/app --rm -it etiennenapoleone/docker-python-poetry bash";

    mk_start = "sudo minikube start";
    mk_con = "eval $(sudo minikube docker-env)";
    mk_context = "sudo kubectl config use-context minikube";
    mk_ip = "sudo minikube ip";
    mk_dash = "sudo minikube dashboard";
    azurite = "docker run --rm --name=azurite --log-driver=journald -p '10000:10000' -p '10001:10001' -v 'azurite_blob:/data' mcr.microsoft.com/azure-storage/azurite";

    # Docker cleanup tasks
    dclean-cache = "sudo systemctl start docker-cleanup-cache";
    dclean-images = "sudo systemctl start docker-cleanup-images";
    dclean-volumes = "sudo systemctl start docker-cleanup-volumes";
    dclean-all = "sudo systemctl start docker-cleanup-cache docker-cleanup-images docker-cleanup-volumes";
    dclean-status = "systemctl status docker-cleanup-cache docker-cleanup-images docker-cleanup-volumes";
  };
}
