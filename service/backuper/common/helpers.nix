{ lib }:
{
  endpointAssertions = name: cfg: [
    {
      assertion = cfg.target != "";
      message = "${name}.target must not be empty.";
    }
    {
      assertion = lib.hasPrefix "/" cfg.secretFile && !(lib.hasPrefix "/nix/store/" cfg.secretFile);
      message = "${name}.secretFile must be an absolute runtime file path outside /nix/store.";
    }
  ];
}
