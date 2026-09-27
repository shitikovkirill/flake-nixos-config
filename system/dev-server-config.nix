{ lib, ... }:

with lib;

{
  options.custom.devServerConfig = {
    codePath = mkOption {
      type = types.str;
      default = "~/Code";
      description = "Default code directory for tools like `h`.";
      example = "~/Code";
    };
  };
}
