{ config, pkgs, lib, ... }:
let domain = "minio.local";
in {
  imports = [ ../default.nix ];

  services.minioService = {
    enable = true;
    https = false;
    inherit domain;
  };

  networking.hosts = { "127.0.0.1" = [ domain ]; };
}
