{ config, lib, pkgs, ... }:
let
  users = import (users.nix);
in {
  services.systemUsers = {
      enable = true;
      inherit users;
    };
}

