{ config, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

    # 1. Disable unsupported power management
    powerManagement.enable = false;

    # 2. Required for proper screen output in Sync mode
    modesetting.enable = true;
    nvidiaSettings = true;

    # PRIME Configuration (Mandatory for Laptops)
    # Get these IDs by running: nix-shell -p pciutils --run "lspci | grep -E 'VGA|3D'"
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      # 3. Switch to Sync mode (supported since driver 390.67)
      sync.enable = true;

      # 4. Remove offload settings as they are incompatible
      offload.enable = false;
      offload.enableOffloadCmd = false;
    };
  };

  # 5. Updated 2025 graphics settings
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
### Check
# lspci | grep -i nvidia
# nvidia-smi
