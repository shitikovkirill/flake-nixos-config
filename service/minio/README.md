# minio

## Usage
```nix
{ config, pkgs, ... }:
let
    package = builtins.fetchGit {
        url = "https://git.webwave.work/Nix/minio.git";
        rev = "a6e6e85875a520368df2c0b69c9c4b3df11278c0";
    };
in {
    imports = [ "${package}" ];

    services.minioService = {
        enable = true;
        https = false;
        inherit domain;
    };

    networking.hosts = { "127.0.0.1" = [ domain "ui.${domain}" ]; };
}
```

## Using nixos containers
```
sudo nixos-container create $MASHINE_NAME
sudo nixos-container start  $MASHINE_NAME
sudo nixos-container update $MASHINE_NAME --config-file $CONFIG_FILE --nixos-path $FREEZE_NIXP
```
