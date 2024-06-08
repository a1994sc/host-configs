{ pkgs, inputs, ... }:

{
  # keep-sorted start block=yes case=no
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
  environment = {
    budgie.excludePackages = with pkgs; [ xterm ];
    systemPackages = with pkgs; [
      staging.pcsclite
      gnome.gnome-disk-utility
    ];
  };
  hardware.pulseaudio.enable = false;
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };
  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    firewall.enable = true;
    hostName = "puck"; # Define your hostname.
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
  };
  programs = {
    gnome-disks.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mtr.enable = true;
  };
  security.rtkit.enable = true;
  services = {
    # keep-sorted start block=yes case=no
    dbus.packages = [ pkgs.gnome.gnome-disk-utility ];
    fwupd.enable = true;
    networkd-dispatcher = {
      enable = true;
      rules = {
        "tailscale" = {
          onState = [ "routable" ];
          script = ''
            #!${pkgs.runtimeShell}
            ${pkgs.ethtool}/bin/ethtool -K eno1 rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      };
    };
    pcscd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      package = pkgs.unstable.tailscale;
    };
    udev.packages = [ pkgs.yubikey-personalization ];
    xserver = {
      # keep-sorted start
      desktopManager.budgie.enable = true;
      displayManager.lightdm.enable = true;
      enable = true;
      layout = "us";
      xkbVariant = "";
      # keep-sorted end
    };
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
  users.users = {
    ascii.packages = with pkgs; [
      # keep-sorted start
      docker
      firefox
      gnupg
      google-chrome
      podman
      # keep-sorted end
    ];
    vroze = {
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
  };
  xdg.portal.enable = true;
  # keep-sorted end
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };
}
