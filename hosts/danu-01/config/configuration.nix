{
  inputs,
  system,
  lib,
  pkgs,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
in
{
  imports = [
    (inputs.self.outPath + "/modules")
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
          "100.89.86.119"
        ];
        ssl.enable = true;
        alts = {
          # keep-sorted start block=yes
          "ascii" = {
            url = "https://a1994sc.cachix.org";
            key = "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI=";
          };
          "community" = {
            url = "https://nix-community.cachix.org";
            key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
          };
          "numtide" = {
            url = "https://numtide.cachix.org";
            key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
          };
          "terra" = {
            url = "https://nixpkgs-terraform.cachix.org";
            key = "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";
          };
          # keep-sorted end
        };
      };
      step = {
        enable = true;
        dnsNames = [
          "10.3.10.5"
          "10.3.20.5"
          "danu-01.adrp.xyz"
        ];
        age.pass = inputs.self.outPath + "/encrypt/step-ca/pass.age";
        age.key = inputs.self.outPath + "/encrypt/step-ca/ca.key.age";
      };
    };
    security.certs = {
      enable = true;
      name = "danu-01.adrp.xyz";
      sans = [
        "10.3.10.5"
        "10.3.20.5"
        "100.89.86.119"
        "keycloak.danu-01.adrp.xyz"
      ] ++ (builtins.map (alt: "${alt}.${danu-01.domain}") (builtins.attrNames danu-01.alts));
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
      "keycloak.danu-01.adrp.xyz"
    ] ++ (builtins.map (alt: "${alt}.${danu-01.domain}") (builtins.attrNames danu-01.alts));
    "10.3.10.6" = [
      "danu-02.adrp.xyz"
    ] ++ (builtins.map (alt: "${alt}.${danu-02.domain}") (builtins.attrNames danu-02.alts));
  };

  nix.settings.substituters =
    [
      "https://${danu-01.domain}?priority=15"
      "https://${danu-02.domain}?priority=10"
    ]
    ++ (builtins.map (alt: "https://${alt}.${danu-01.domain}?priority=15") (
      builtins.attrNames danu-01.alts
    ))
    ++ (builtins.map (alt: "https://${alt}.${danu-02.domain}?priority=10") (
      builtins.attrNames danu-02.alts
    ));

  nix.gc.dates = "Thu 02:00";
  system.autoUpgrade.dates = "Thu 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
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
    permitCertUid = "1000";
    useRoutingFeatures = "server";
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
    nameservers = [
      "10.3.10.5"
      "10.3.10.6"
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
