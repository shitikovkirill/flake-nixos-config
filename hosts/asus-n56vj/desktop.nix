# GUI/workstation profile for this machine.
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  # kirill's account itself comes from services.systemUsers (system/data);
  # this just adds the GUI-only package on top of it.
  users.users.kirill.packages = [ pkgs.kdePackages.kate ];
}
