# GUI/workstation profile for this machine. xserver/sddm/plasma6 and audio
# come from the shared ./desktop module.
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    # sap plugin fights bluetoothd on this hardware — keep it off.
    disabledPlugins = [ "sap" ];
  };
}
