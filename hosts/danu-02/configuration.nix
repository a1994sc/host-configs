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

  ascii.system.dns.enable = true;

  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
  ];

  nix.gc.dates = "Tue 02:00";
  system.autoUpgrade.dates = "Tue 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  services.resolved.enable = false;

  systemd.network = {
    enable = true;
    links = {
      "00-core" = {
        matchConfig.PermanentMACAddress = "c4:65:16:1f:d1:65";
        linkConfig.Name = "eth0";
      };
      "10-machine" = {
        matchConfig.PermanentMACAddress = "0c:37:96:44:49:14";
        linkConfig.Name = "machine0";
      };
    };
    networks = {
      "00-core" = {
        matchConfig = {
          MACAddress = "c4:65:16:1f:d1:65";
          Type = "ether";
        };
        address = [
          "10.3.10.7/24"
        ];
        routes = [
          { routeConfig.Gateway = "10.3.10.1"; }
        ];
      };
      "10-machine" = {
        matchConfig = {
          MACAddress = "0c:37:96:44:49:14";
          Type = "ether";
        };
        address = [
          "10.3.20.7/23"
        ];
        routes = [
          { routeConfig.Gateway = "10.3.20.1"; }
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
            8080 # Matchbox
            8443 # Matchbox
          ];
        };
      in
      {
        eth0 = FIREWALL_PORTS;
        machine0 = FIREWALL_PORTS;
      };
    interfaces.eth0.useDHCP = lib.mkForce false;
  };
}
