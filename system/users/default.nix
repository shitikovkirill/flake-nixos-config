{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.systemUsers;
  motd = with config; ''
    Welcome to ${networking.hostName}

    - This machine is managed by NixOS

    OS:      NixOS ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}
  '';
in {
  options = {
    services.systemUsers = {
      enable = mkOption {
        default = false;
        description = ''
          Add users to system
        '';
      };
      users = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = ''
                User name.
              '';
            };
            description = mkOption {
              type = types.str;
              default = "";
              description = ''
                Description.
              '';
            };
            groups = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc "User groups.";
            };
            keys = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc "User kays.";
            };
          };
        });
        default = [ ];
        description = ''
          List of users.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users = {
      mutableUsers = false;
      inherit motd;
      users = listToAttrs (map (u: {
        name = u.name;
        value = {
          isNormalUser = true;
          description = u.description;
          extraGroups = u.groups;
          openssh.authorizedKeys.keys = u.keys;
        };
      }) cfg.users);
    };
  };
}
