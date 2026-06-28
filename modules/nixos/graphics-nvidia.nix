{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.blacklistedKernelModules = [ "nouveau" ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
