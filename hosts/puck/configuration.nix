{ pkgs, inputs, ... }:

{
  # keep-sorted start block=yes case=no
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  environment.budgie.excludePackages = with pkgs; [ xterm ];
  hardware.pulseaudio.enable = false;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    # keep-sorted start
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    # keep-sorted end
  };
  environment.systemPackages = [ pkgs.staging.pcsclite ];
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;
  networking.hostName = "puck"; # Define your hostname.
  networking.networkmanager.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.mtr.enable = true;
  security.rtkit.enable = true;
  services.pcscd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.xserver = {
    # keep-sorted start
    desktopManager.budgie.enable = true;
    displayManager.lightdm.enable = true;
    enable = true;
    layout = "us";
    xkbVariant = "";
    # keep-sorted end
  };
  sound.enable = true;
  system.autoUpgrade = {
    # keep-sorted start block=yes case=no
    dates = "02:00";
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L"
    ];
    flake = inputs.self.outPath;
    randomizedDelaySec = "45min";
    # keep-sorted end
  };
  system.stateVersion = "23.11";
  users.users.ascii.packages = with pkgs; [
    # keep-sorted start
    docker
    firefox
    gnupg
    google-chrome
    podman
    # keep-sorted end
  ];
  users.users.vroze = {
    # keep-sorted start block=yes case=no
    description = "Victoria Roze";
    extraGroups = [ ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ ];
    packages = with pkgs; [
      google-chrome
      firefox
    ];
    uid = 1001;
    # keep-sorted end
  };
  # keep-sorted end
  services.tailscale.enable = true;
  # services.pcscd.enable = true;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
