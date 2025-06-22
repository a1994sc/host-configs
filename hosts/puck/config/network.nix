{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii;
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  time.timeZone = "America/New_York";
  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    firewall.enable = true;
    hostName = "puck";
    domain = "adrp.xyz";
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    nameservers = [
      "100.100.100.100"
      "10.3.10.5"
      "10.3.10.6"
      "9.9.9.9"
    ];
    hosts = {
      "100.89.86.119" =
        [
          "danu-01.adrp.xyz"
        ]
        ++ (lib.lists.unique (
          (builtins.filter (name: builtins.match ".*\\.xyz" name != null) danu-01.security.certs.sans)
          ++ (builtins.map (alt: "${alt}.${danu-01.system.cache.domain}") (
            builtins.attrNames danu-01.system.cache.alts
          ))
        ));
      "100.126.110.27" =
        [
          "danu-02.adrp.xyz"
        ]
        ++ (lib.lists.unique (
          (builtins.filter (name: builtins.match ".*\\.xyz" name != null) danu-02.security.certs.sans)
          ++ (builtins.map (alt: "${alt}.${danu-02.system.cache.domain}") (
            builtins.attrNames danu-02.system.cache.alts
          ))
        ));
    };
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
