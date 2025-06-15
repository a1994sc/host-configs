{
  config,
  pkgs,
  inputs,
  outputs,
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

  networking.hosts =
    let
      danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
      danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
    in
    {
      "10.3.10.5" = [
        "danu-01.adrp.xyz"
      ] ++ (builtins.map (alt: "${alt}.${danu-01.domain}") (builtins.attrNames danu-01.alts));
      "10.3.10.6" = [
        "danu-02.adrp.xyz"
      ] ++ (builtins.map (alt: "${alt}.${danu-02.domain}") (builtins.attrNames danu-02.alts));
    };

  # nix.settings.substituters = [
  #   "https://danu-01.adrp.xyz?priority=10"
  #   "https://danu-02.adrp.xyz?priority=10"
  #   "https://ascii.danu-01.adrp.xyz?priority=15"
  #   "https://ascii.danu-02.adrp.xyz?priority=15"
  # ];

  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
  ];
}
