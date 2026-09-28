# Headless/server profile for this machine — no display manager, no audio.
{ config, ... }:

{
  services.openssh.enable = true;

  environment.shellAliases = {
    monitor_off = "sudo setterm --blank force";
    monitor_on = "sudo setterm --blank poke";
  };
}
