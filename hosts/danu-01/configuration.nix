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
        domain = "danu-01.adrp.xyz";
        sans = [
          "10.3.10.5"
          "10.3.20.5"
          # "cache.10.3.10.5.nip.io"
          # "ascii.10.3.10.5.nip.io"
        ];
        ssl.enable = true;
        alts = {
          "ascii" = "https://a1994sc.cachix.org";
          "terra" = "https://nixpkgs-terraform.cachix.org";
        };
      };
      step = {
        enable = true;
        dnsNames = [
          "10.3.10.5"
          "10.3.20.5"
          "danu-01.adrp.xyz"
        ];
        age.pass = ../../encrypt/step-ca/pass.age;
        age.key = ../../encrypt/step-ca/ca.key.age;
      };
    };
    security.certs = {
      enable = true;
      name = "danu-01.adrp.xyz";
      sans = [
        "10.3.10.5"
        "10.3.20.5"
        "ascii.danu-01.adrp.xyz"
        "terra.danu-01.adrp.xyz"
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

  nix.gc.dates = "Thu 02:00";
  nix.settings.substituters = [
    "https://danu-01.adrp.xyz?priority=15"
    "https://danu-02.adrp.xyz?priority=10"
    "https://ascii.danu-01.adrp.xyz?priority=15"
    "https://ascii.danu-02.adrp.xyz?priority=10"
  ];
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
  ];
  system.autoUpgrade.dates = "Thu 04:00";
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
          ];
          allowedTCPPorts = [
            22 # SSH
            53 # DNS
            80 # HTTP
            443 # HTTPS
            1443 # STEP-CA
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
