{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  toSystemdIni = lib.generators.toINI {
    listsAsDuplicateKeys = true;
    mkKeyValue =
      key: value:
      let
        value' =
          if lib.isBool value then
            (if value then "true" else "false")
          else
            (if lib.isString value then "'${value}'" else toString value);
      in
      "${key}=${value'}";
  };
in
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
  hardware = {
    pulseaudio.enable = false;
    # opengl = {
    #   ## radv: an open-source Vulkan driver from freedesktop
    #   driSupport = true;
    #   driSupport32Bit = true;
    # };
  };
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
  nixpkgs.config.allowUnfreePredicate =
    pkgs:
    builtins.elem (pkgs.lib.getName pkgs) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  programs = {
    gnome-disks.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mtr.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.unstable.steam.override {
        extraLibraries = pkgs: [
          pkgs.openssl
          pkgs.nghttp2
          pkgs.libidn2
          pkgs.rtmpdump
          pkgs.libpsl
          pkgs.curl
          pkgs.krb5
          pkgs.keyutils
        ];
      };
    };
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
      port = 0;
      useRoutingFeatures = "client";
      package = pkgs.unstable.tailscale;
      permitCertUid = "1000";
      extraUpFlags = [
        "--operator=${config.users.users.ascii.name}"
        # "--ssh"
        "--accept-routes=true"
      ];
    };
    udev.packages = [ pkgs.yubikey-personalization ];
    xserver = {
      # keep-sorted start block=yes
      desktopManager.budgie = {
        enable = true;
        extraGSettingsOverridePackages = [ pkgs.gnome.gnome-settings-daemon ];
        extraGSettingsOverrides = toSystemdIni {
          "org.gnome.desktop.screensaver" = {
            picture-uri = "file:///etc/nixos/home/wallpaper/lockscreen.png";
          };
          "org.gnome.desktop.interface" = {
            scaling-factor = 2;
            text-scaling-factor = 0.87;
          };
        };
      };
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
