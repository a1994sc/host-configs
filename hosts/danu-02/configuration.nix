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
    ../../modules/matchbox
  ];

  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
  ];

  nix.gc.dates = "Tue 02:00";
  system.autoUpgrade.dates = "Tue 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  networking = {
    hostName = "danu-02";
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
            4011 # TFTP
          ];
          allowedTCPPorts = [
            22 # SSH
            53 # DNS
            443 # Netbox
            8080 # Matchbox
            8443 # Matchbox
          ];
        };
      in
      {
        eth0 = FIREWALL_PORTS;
        vlan20 = FIREWALL_PORTS;
      };
    vlans.vlan20 = {
      id = 20;
      interface = "eth0";
    };
    interfaces = {
      eth0.ipv4.addresses = [
        {
          address = "10.3.10.7";
          prefixLength = 24;
        }
      ];
      vlan20 = {
        useDHCP = false;
        macAddress = "02:F1:A1:17:21:CF";
        ipv4.addresses = [
          {
            address = "10.3.20.7";
            prefixLength = 23;
          }
        ];
      };
    };
  };
}
