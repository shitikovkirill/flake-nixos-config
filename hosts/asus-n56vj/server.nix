# Headless/server profile for this machine — no display manager, no audio.
{ config, ... }:

{
  services.openssh.enable = true;

  environment.shellAliases = {
    monitor_off = "sudo setterm --blank force";
    monitor_on = "sudo setterm --blank poke";
    battery = "cat /sys/class/power_supply/BAT0/capacity; cat /sys/class/power_supply/BAT0/status";
  };
}
