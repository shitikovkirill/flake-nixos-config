{ config, ... }:

{
  # Built-in Docker Registry
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    storagePath = "/home/docker-registry/data";

    extraConfig = {
      delete.enabled = true;
      storage.redirect.disable = false;
    };
  };
}
