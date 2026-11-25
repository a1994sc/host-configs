{
  config,
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
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  boot.initrd.kernelModules = [
    "loop"
    "overlay"
    "amdgpu"
  ];

  boot.kernelModules = [
    "kvm-amd"
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

  networking.hosts = {
    "10.3.10.5" = [ "danu-01.adrp.xyz" ];
    "10.3.10.6" = [ "danu-02.adrp.xyz" ];
  };

  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
  ];
}
