{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
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
    systemPackages = with pkgs; [
      staging.pcsclite
      speedcrunch
      vanilla-dmz
      kdePackages.discover
    ];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      # SSH_ASKPASS_REQUIRE = "prefer";
    };
  };
  hardware = {
    pulseaudio.enable = false;
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
    nameservers = [
      "100.100.100.100" # magic dns, tailscale
      "10.3.10.5" # adrp.xyz, primary
      "10.3.10.6" # adrp.xyz, replica
      "9.9.9.9" # fallback, clear web
    ];
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
    file-roller.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true;
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
    pcscd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire = {
        "99-silent-bell" = {
          "context.properties" = {
            "module.x11.bell" = false;
          };
        };
      };
    };
    resolved = {
      enable = true;
      domains = [
        "adrp.xyz"
        "barb-neon.ts.net"
      ];
    };
    tailscale = {
      enable = true;
      port = 0;
      useRoutingFeatures = "client";
      package = pkgs.unstable.tailscale;
      permitCertUid = "1000";
      extraUpFlags = [
        "--operator=${config.users.users.ascii.name}"
        "--accept-routes=true"
      ];
    };
    udev.packages = [ pkgs.yubikey-personalization ];
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";
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
  services.xserver = {
    # keep-sorted start block=yes
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm.enable = true;
      lightdm.enable = lib.mkForce false;
      defaultSession = "plasma";
    };
    excludePackages = [ pkgs.xterm ];
    # keep-sorted end
  };
  users = {
    groups = {
      ascii = {
        gid = config.users.users.ascii.uid;
        name = "ascii";
      };
      vroze = {
        gid = config.users.users.vroze.uid;
        name = "vroze";
      };
    };
    users = {
      ascii.packages = with pkgs; [
        # keep-sorted start
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
  };
  xdg.portal.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };
}
