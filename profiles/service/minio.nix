{ config, pkgs, ... }:
let
  domain = "minio.home";
in
{
  imports = [ ../../service/minio ];

  nixpkgs.config.permittedInsecurePackages = [
    "minio-2025-10-15T17-29-55Z"
  ];

  services.minio.listenAddress = ":9900";
  services.minio.consoleAddress = ":9901";

  services.minioService = {
    enable = true;
    https = false;
    inherit domain;
    dataDir = "/home/lib/minio/data";
  };

  networking.hosts = {
    "127.0.0.1" = [
      domain
      "ui.${domain}"
    ];
  };
}
