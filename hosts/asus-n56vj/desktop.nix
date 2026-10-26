# GUI/workstation profile for this machine.
{ config, pkgs, ... }:

{
  # xserver/sddm/plasma6 come from the shared ./desktop module.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  programs.firefox.enable = true;

  # kirill's account itself comes from services.systemUsers (system/data);
  # this just adds the GUI-only package on top of it.
  users.users.kirill.packages = [ pkgs.kdePackages.kate ];
}
