# Headless/server profile for this machine — no display manager, no audio.
{ config, ... }:

{
  imports = [ ./lid-switch.nix ];

  services.openssh.enable = true;

  services.ecsAnywhere = {
    enable = true;
    cluster = "PhotoSaver-PSClusterE98E69D4-ff8jz33nFro0";
    region = "eu-central-1";
  };

  environment.shellAliases = {
    monitor_off = "echo 1 | sudo tee /sys/class/graphics/fb0/blank";
    monitor_on = "echo 0 | sudo tee /sys/class/graphics/fb0/blank";
    battery = "cat /sys/class/power_supply/BAT0/capacity; cat /sys/class/power_supply/BAT0/status";
  };
}
