{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ dbeaver-bin ];
}
