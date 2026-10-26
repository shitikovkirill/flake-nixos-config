{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ redisinsight ];
}
