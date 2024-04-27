{
  config,
  lib,
  pkgs,
  ...
}:
let
  path = "/etc/nixos";
in
{
  imports = [
    "${path}/modules/main-config.nix"
    "${path}/modules/sops.nix"
    "${path}/modules/bare.nix"
  ];

  # Fixed issues where the dell wyse cpu locks up on idel.
  boot.kernelParams = [ "intel_idle.max_cstate=1" ];

  nix.gc.dates = "Wed 02:00";
  system.autoUpgrade.dates = "Wed 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;
  networking = {
    hostName = "box";
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.enable = pkgs.lib.mkForce true;
    firewall.interfaces =
      let
        FIREWALL_PORTS = {
          allowedTCPPorts = [
            22 # SSH
            443 # Netbox
          ];
        };
      in
      {
        eth0 = (FIREWALL_PORTS);
      };
    interfaces = {
      eth0.ipv4.addresses = [
        {
          address = "10.3.10.8";
          prefixLength = 24;
        }
      ];
    };
  };
}
