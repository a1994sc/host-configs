{
  system,
  lib,
  pkgs,
  outputs,
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
    # disabled because it does not play nice with custom dns servers
    enable = false;
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

  systemd.network = {
    enable = true;
    links = {
      "00-core" = {
        matchConfig.PermanentMACAddress = "c4:65:16:1f:d1:65";
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
          MACAddress = "c4:65:16:1f:d1:65";
          Type = "ether";
        };
        address = [
          "10.3.10.6/24"
        ];
        routes = [
          { Gateway = "10.3.10.1"; }
        ];
        vlan = [
          "vlan20"
        ];
        dns = [
          "1.1.1.2"
          "1.0.0.2"
        ];
      };
      "40-vlan20" = {
        enable = false;
        matchConfig.Name = "vlan20";
        address = [
          "10.3.20.6/23"
        ];
        routes = [
          { Gateway = "10.3.20.1"; }
        ];
        dns = [
          "1.1.1.2"
          "1.0.0.2"
        ];
      };
    };
  };

  networking = {
    hostName = "danu-02";
    useNetworkd = true;
    useDHCP = false;
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
          ];
        };
      in
      {
        eth0 = FIREWALL_PORTS;
        vlan20 = FIREWALL_PORTS;
      };
    interfaces.eth0.useDHCP = lib.mkForce false;
  };
}
