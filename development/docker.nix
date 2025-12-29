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
  };

  users.users.kirill.extraGroups = [ "docker" ];

  programs.zsh = { ohMyZsh = { plugins = [ "docker" "docker-compose" ]; }; };

  environment.shellAliases = {
    drmc = "docker rm $(docker ps -a -q)";
    drimage = "docker rmi $(docker images -q)";
    drdimage =
      "docker rmi $(docker images --filter 'dangling=true' -q --no-trunc)";
    drvolume = "docker volume rm $(docker volume ls -q --filter dangling=true)";
    drnetwork = "docker network prune";
    dclearall = "docker system prune -a -f";
    dstopc = "docker stop $(docker ps -aq)";
    dstopc_with_restart_always =
      "docker stop $(docker ps -a -q) & docker update --restart=no $(docker ps -a -q) & systemctl restart docker";
    dnorestart = "docker update --restart=no $(docker ps -aq)";
    dhist = "docker history --no-trunc";
    dlint = ''
      docker run --rm -i hadolint/hadol  environment.systemPackages = with pkgs; [
          python3
        ];int'';
    dlint-deb =
      "docker run -v $(pwd):/app:ro --workdir=/app --rm -i hadolint/hadolint:latest-debian hadolint";
    dpoetry =
      "docker run -v $(pwd):/app --workdir=/app --rm -it etiennenapoleone/docker-python-poetry bash";

    mk_start = "sudo minikube start";
    mk_con = "eval $(sudo minikube docker-env)";
    mk_context = "sudo kubectl config use-context minikube";
    mk_ip = "sudo minikube ip";
    mk_dash = "sudo minikube dashboard";
    azurite =
      "docker run --rm --name=azurite --log-driver=journald -p '10000:10000' -p '10001:10001' -v 'azurite_blob:/data' mcr.microsoft.com/azure-storage/azurite";
  };
}
