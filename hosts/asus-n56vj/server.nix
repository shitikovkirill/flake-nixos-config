# Headless/server profile for this machine — no display manager, no audio.
{ config, ... }:

{
  services.openssh.enable = true;
}
