{
  config,
  lib,
  modulesPath,
  pkgs,
  inputs,
  ...
}:

{
  isoImage = {
    isoName = "NixOSLive.iso";
    squashfsCompression = "zstd";

    appendToMenuLabel = "Live";
    makeEfiBootable = true; # EFI booting
    makeUsbBootable = true; # USB booting
  };

  swapDevices = [ ];

  boot.kernelParams = [
    "root=LABEL=${config.isoImage.volumeID}"
    "boot.shell_on_fail"
  ];

  boot.initrd.availableKernelModules = [
    "squashfs"
    "iso9660"
    "uas"
    "overlay"
  ];

  boot.initrd.kernelModules = [
    "loop"
    "overlay"
  ];

  boot = {
    tmp.cleanOnBoot = true;
    kernel.sysctl = {
      "kernel.unprivileged_bpf_disabled" = 1;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.getty.autologinUser = "root";

  users.users.root.initialHashedPassword = "";

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  environment.systemPackages = with pkgs; [
    parted
    tmux
    htop
    git
    libxfs
    nh
    nano
    micro
    inputs.disko.packages.${system}.disko
  ];

  system.stateVersion = "24.11";
}
