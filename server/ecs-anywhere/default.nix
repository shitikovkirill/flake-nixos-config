# Registers this machine with an ECS cluster as an ECS Anywhere (EXTERNAL)
# container instance, using NixOS's native `services.amazon-ssm-agent` and
# `services.ecs-agent` modules instead of AWS's install script — that script
# only knows how to install .deb/.rpm packages and manage them with
# systemctl/sysvinit directly, which doesn't work on NixOS.
#
# This module only wires up the two agents and their required environment;
# the one-time SSM hybrid activation still has to be run by hand after the
# first `nixos-rebuild switch`. See docs/pages/server/ecs-anywhere.md for the
# full runbook (creating the activation, registering, IAM, verification).
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ecsAnywhere;
in
{
  options.services.ecsAnywhere = {
    enable = lib.mkEnableOption "registering this machine as an ECS Anywhere (EXTERNAL) container instance";

    cluster = lib.mkOption {
      type = lib.types.str;
      description = "Name of the ECS cluster this instance registers with (ECS_CLUSTER).";
    };

    region = lib.mkOption {
      type = lib.types.str;
      description = "AWS region of the ECS cluster and the SSM activation (AWS_DEFAULT_REGION).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.amazon-ssm-agent.enable = true;

    services.ecs-agent = {
      enable = true;
      extra-environment = {
        ECS_CLUSTER = cfg.cluster;
        ECS_EXTERNAL = "true";
        AWS_DEFAULT_REGION = cfg.region;
        # NixOS updates packages by rebuilding the system, not via the
        # agent's own self-update mechanism.
        ECS_UPDATES_ENABLED = "false";
        # Mutable, non-store directory so the agent's container-instance
        # state survives reboots/rebuilds instead of re-registering as a
        # new instance every time.
        ECS_DATADIR = "/var/lib/ecs/data";
        # On a hybrid-registered instance, amazon-ssm-agent refreshes
        # temporary credentials into ~/.aws/credentials (default profile)
        # for local processes to pick up — that's how ecs-agent gets ECS
        # Anywhere credentials. Both services run as root with no `User=`,
        # so systemd never sets $HOME for them; without it, the Go AWS SDK
        # (os.UserHomeDir()) can't find that file at all.
        HOME = "/root";
      };
    };

    systemd.services.amazon-ssm-agent.environment.HOME = "/root";

    # ecs-agent needs amazon-ssm-agent to have already written the shared
    # credentials file it reads on startup, so it has to come up after SSM
    # is running, not just after the network.
    systemd.services.ecs-agent = {
      after = [ "amazon-ssm-agent.service" ];
      wants = [ "amazon-ssm-agent.service" ];
    };

    # Needed on the host PATH for the one-time
    # `amazon-ssm-agent -register ...` activation step.
    environment.systemPackages = [ pkgs.amazon-ssm-agent ];
  };
}
