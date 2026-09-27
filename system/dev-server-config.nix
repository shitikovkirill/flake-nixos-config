{ lib, ... }:

with lib;

{
  options.custom.devServerConfig = {
    user = mkOption {
      type = types.str;
      description = "Primary username this machine's config is built around.";
      example = "kirill";
    };
    codePath = mkOption {
      type = types.str;
      default = "~/Code";
      description = "Default code directory for tools like `h`.";
      example = "~/Code";
    };
  };
}
