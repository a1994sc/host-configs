{ lib, pkgs, ... }:
{
  imports = [
    ../../modules
    ../../modules/sops
    ../../modules/bare
    ../../modules/dns
    ../../modules/matchbox
    ../../modules/powerdns/replica
  ];

  # Fixed issues where the dell wyse cpu locks up on idel.
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];

  nix.gc.dates = "Fri 02:00";
  system.autoUpgrade.dates = "Fri 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_8;
  networking = {
    hostName = "dns2";
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
          address = "10.3.10.6";
          prefixLength = 24;
        }
      ];
      vlan20 = {
        useDHCP = false;
        macAddress = "02:08:E1:DF:6D:0C";
        ipv4.addresses = [
          {
            address = "10.3.20.6";
            prefixLength = 23;
          }
        ];
      };
    };
  };
}
