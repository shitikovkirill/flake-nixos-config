{ config, pkgs, ... }:

{
  # Docker-related system packages
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

  # Zsh plugins for Docker
  programs.zsh = {
    ohMyZsh = {
      plugins = [
        "docker"
        "docker-compose"
      ];
    };
  };

  # Shell aliases for Docker commands
  environment.shellAliases = {
    dhist = "docker history --no-trunc";
    dlint = "docker run --rm -i hadolint/hadolint";
    dlint-deb = "docker run -v $(pwd):/app:ro --workdir=/app --rm -i hadolint/hadolint:latest-debian hadolint";
    dpoetry = "docker run -v $(pwd):/app --workdir=/app --rm -it etiennenapoleone/docker-python-poetry bash";

    # Minikube shortcuts
    mk_start = "sudo minikube start";
    mk_con = "eval $(sudo minikube docker-env)";
    mk_context = "sudo kubectl config use-context minikube";
    mk_ip = "sudo minikube ip";
    mk_dash = "sudo minikube dashboard";

    # Container shortcuts
    azurite = "docker run --rm --name=azurite --log-driver=journald -p '10000:10000' -p '10001:10001' -v 'azurite_blob:/data' mcr.microsoft.com/azure-storage/azurite";
  };
}
