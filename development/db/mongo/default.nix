{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ mongosh ];
}
