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
    ../../modules/bare
    ../../modules/dns
  ];

  ascii.system.dns.enable = true;

  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
  ];

  nix.gc.dates = "Thu 02:00";
  system.autoUpgrade.dates = "Thu 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
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
          "10.3.10.8/24"
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
          "10.3.20.8/23"
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
          ];
        };
      in
      {
        eth0 = FIREWALL_PORTS;
      };
    interfaces.eth0.useDHCP = lib.mkForce false;
  };
}
