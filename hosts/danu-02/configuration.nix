{
  inputs,
  system,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules
  ];

  ascii = {
    system = {
      bare.enable = true;
      dns.enable = true;
      cache = {
        enable = true;
        domain = "danu-02.adrp.xyz";
        sans = [
          "10.3.10.6"
          "10.3.20.6"
        ];
        ssl.enable = true;
      };
      matchbox = {
        enable = true;
        talosVersion = "1-9";
        age.ca = ../../encrypt/matchbox/ca.crt.age;
        age.crt = ../../encrypt/matchbox/tls.crt.age;
        age.key = ../../encrypt/matchbox/tls.key.age;
        age.env = ../../encrypt/matchbox/env.age;
      };
    };
    security.certs = {
      enable = true;
      name = "danu-02.adrp.xyz";
      sans = [
        "10.3.10.6"
        "10.3.20.6"
        "ascii.danu-02.adrp.xyz"
        "terra.danu-02.adrp.xyz"
      ];
    };
  };

  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
    pkgs.duf
    pkgs.rage
  ];

  networking.hosts = {
    "10.3.10.5" = [
      "danu-01.adrp.xyz"
      "ascii.danu-01.adrp.xyz"
      "terra.danu-01.adrp.xyz"
    ];
    "10.3.10.6" = [
      "danu-02.adrp.xyz"
      "ascii.danu-02.adrp.xyz"
      "terra.danu-02.adrp.xyz"
    ];
  };

  nix.gc.dates = "Tue 02:00";
  nix.settings.substituters = [
    "https://danu-01.adrp.xyz?priority=10"
    "https://danu-02.adrp.xyz?priority=15"
  ];
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
  ];
  system.autoUpgrade.dates = "Tue 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  boot.kernel.sysctl = {
    "net.ipv4.conf.default.arp_filter" = 1;
    "net.ipv4.conf.all.arp_filter" = 1;
  };

  services.resolved.enable = false;

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
      };
      "40-vlan20" = {
        matchConfig.Name = "vlan20";
        address = [
          "10.3.20.6/23"
        ];
        routes = [
          { Gateway = "10.3.20.1"; }
        ];
      };
    };
  };

  networking = {
    hostName = "danu-02";
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
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
            4011 # TFTP
          ];
          allowedTCPPorts = [
            22 # SSH
            53 # DNS
            80 # HTTP
            443 # HTTPS
            8080 # Matchbox
            8443 # Matchbox
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
