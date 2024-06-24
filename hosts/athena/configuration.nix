{ lib, pkgs, ... }:
{
  imports = [
    ../../modules
    ../../modules/dns
  ];

  nix.gc.dates = "Tue 02:00";
  system.autoUpgrade.dates = "Tue 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  networking = {
    hostName = "athena";
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable = pkgs.lib.mkForce true;
    firewall.interfaces = {
      eth0 = {
        allowedUDPPorts = [
          53 # DNS
        ];
        allowedTCPPorts = [
          22 # SSH
          53 # DNS
        ];
      };
    };
    interfaces = {
      eth0.ipv4.addresses = [
        {
          # address = "10.3.10.6";
          address = "10.3.10.10";
          prefixLength = 24;
        }
      ];
    };
  };
}
