{
  system,
  lib,
  pkgs,
  outputs,
  config,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii;
in
{
  networking.hosts = {
    "10.3.10.5" =
      [
        "danu-01.adrp.xyz"
      ]
      ++ (lib.lists.unique (
        (builtins.filter (name: builtins.match ".*\\.xyz" name != null) danu-01.security.certs.sans)
        ++ (builtins.map (alt: "${alt}.${danu-01.system.cache.domain}") (
          builtins.attrNames danu-01.system.cache.alts
        ))
      ));
    "10.3.10.6" =
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

  boot.kernel.sysctl = {
    "net.ipv4.conf.default.arp_filter" = 1;
    "net.ipv4.conf.all.arp_filter" = 1;
  };

  services.resolved = {
    enable = true;
    domains = [
      "adrp.xyz"
      "barb-neon.ts.net"
    ];
  };

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
    permitCertUid = "1000";
    useRoutingFeatures = "server";
  };

  services.comin = {
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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      LoginGraceTime = 0;
    };
  };

  systemd.network = {
    enable = true;
    links = {
      "00-core" = {
        matchConfig.PermanentMACAddress = "10:e7:c6:14:ae:56";
        linkConfig.Name = "eth0";
      };
    };
    netdevs = {
      "20-vlan20" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan20";
        };
        vlanConfig.Id = 20;
      };
    };
    networks = {
      "00-core" = {
        enable = true;
        matchConfig = {
          MACAddress = "10:e7:c6:14:ae:56";
          Type = "ether";
        };
        address = [
          "10.3.10.5/24"
        ];
        routes = [
          { Gateway = "10.3.10.1"; }
        ];
        vlan = [
          "vlan20"
        ];
      };
      "40-vlan20" = {
        matchConfig.Name = "vlan20";
        address = [
          "10.3.20.5/23"
        ];
        routes = [
          { Gateway = "10.3.20.1"; }
        ];
      };
    };
  };

  networking = {
    hostName = "danu-01";
    domain = "adrp.xyz";
    search = [ "adrp.xyz" ];
    useNetworkd = true;
    useDHCP = false;
    wireless.enable = false;
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable = pkgs.lib.mkForce true;
    firewall.interfaces =
      let
        FIREWALL_PORTS = {
          allowedUDPPorts = [
            53 # DNS
            67 # DHCP
            69 # TFTP
          ];
          allowedTCPPorts = [
            22 # SSH
            53 # DNS
            80 # HTTP
            443 # HTTPS
            1443 # STEP-CA
            50042 # OMNI
            8090 # OMNI
          ];
        };
      in
      {
        eth0 = FIREWALL_PORTS;
      };
    interfaces.eth0.useDHCP = lib.mkForce false;
  };
}
