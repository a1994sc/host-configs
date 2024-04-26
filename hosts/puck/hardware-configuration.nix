{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e629c4ae-f14e-4986-9725-0d6b9f9233ec";
      fsType = "xfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6D29-AB31";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/de30a598-099d-43de-9ca5-a176594381d9";
      fsType = "xfs";
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/e962d688-f132-4e57-bf94-b221c11782b4";
      fsType = "xfs";
    };
    "/tmp" = {
      device = "/dev/disk/by-uuid/87bf9d62-fdbc-4ec0-945c-afdc9e3adbd4";
      fsType = "xfs";
    };
  };
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
