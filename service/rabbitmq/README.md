# Rabbitmq package

## Usage
```nix
{ config, lib, pkgs, ... }:
let
  domain = "rabbitmq.develop";
  package = builtins.fetchGit {
    url = "https://git.webwave.work/Nix/rabbitmq.git";
    rev = "b351f77057ef17ff5d10a3b4c3dc9f44bdb257fc";
  };
in {
  imports = [ "${package}" ];

  services.rbService = {
    enable = true;
    https = false;
    inherit domain;
  };

  networking.hosts = { "127.0.0.1" = [ domain ]; };
}
```

## Using nixos containers
```
sudo nixos-container create $MASHINE_NAME
sudo nixos-container start  $MASHINE_NAME
sudo nixos-container update $MASHINE_NAME --config-file $CONFIG_FILE --nixos-path $FREEZE_NIXP
```
