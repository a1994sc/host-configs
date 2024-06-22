{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # change with the `boot` section after running:
  # $ nixos-generate-config --dir 
  # boot = {
  #   initrd.availableKernelModules = [
  #     "xhci_pci"
  #     "nvme"
  #     "usbhid"
  #     "usb_storage"
  #     "sd_mod"
  #     "sdhci_pci"
  #   ];
  #   initrd.kernelModules = [ ];
  #   kernelModules = [ "kvm-intel" ];
  #   extraModulePackages = [ ];
  # };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
