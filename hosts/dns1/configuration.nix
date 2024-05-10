{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/main-config.nix
    ../../modules/sops.nix
    ../../modules/bare.nix
    ../../modules/dns
    ../../modules/step-ca
    ../../modules/powerdns/primary
  ];

  # Fixed issues where the dell wyse cpu locks up on idel.
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];

  nix.gc.dates = "Mon 02:00";
  system.autoUpgrade.dates = "Mon 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;
  networking = {
    hostName = "dns1";
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
            67 # PXE
            69 # PXE
          ];
          allowedTCPPorts = [
            22 # SSH
            53 # DNS
            443 # STEP-CA
            3306 # DNS
            8443 # PowerDNS API
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
          address = "10.3.10.5";
          prefixLength = 24;
        }
      ];
      vlan20 = {
        useDHCP = false;
        macAddress = "02:F1:A1:15:21:CF";
        ipv4.addresses = [
          {
            address = "10.3.20.5";
            prefixLength = 23;
          }
        ];
      };
    };
  };
}
