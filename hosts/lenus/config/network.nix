{
  pkgs,
  config,
  ...
}:
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  time.timeZone = "America/New_York";
  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    firewall.enable = true;
    hostName = "lenus";
    domain = "adrp.xyz";
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    nameservers = [
      "100.100.100.100"
      "10.3.10.5"
      "10.3.10.6"
      "9.9.9.9"
    ];
  };

  services = {
    # keep-sorted start block=yes case=no
    comin = {
      hostname = config.networking.hostName;
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://github.com/a1994sc/host-configs.git";
          branches.main.name = "main";
        }
      ];
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        LoginGraceTime = 0;
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
    # keep-sorted end
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}
