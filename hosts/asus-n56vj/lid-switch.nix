# Headless server: closing the lid must never suspend the machine, or the
# k3s cluster (and everything deployed on it) goes unreachable until
# someone physically opens it back up. NixOS's default HandleLidSwitch is
# "suspend" regardless of power source/docked state, which is fine for the
# -desktop variant but wrong here.
{ ... }:
{
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
