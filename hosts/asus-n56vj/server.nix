# Headless/server profile for this machine — no display manager, no audio.
{ config, ... }:

{
  services.openssh.enable = true;

  environment.shellAliases = {
    monitor_off = "echo 1 | sudo tee /sys/class/graphics/fb0/blank";
    monitor_on = "echo 0 | sudo tee /sys/class/graphics/fb0/blank";
    battery = "cat /sys/class/power_supply/BAT0/capacity; cat /sys/class/power_supply/BAT0/status";
  };
}
