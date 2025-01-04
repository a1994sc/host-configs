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
    networks = {
      "00-core" = {
        enable = true;
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
    # interfaces.machine0.useDHCP = lib.mkForce false;
  };
}
