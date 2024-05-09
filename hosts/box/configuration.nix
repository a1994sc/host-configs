{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/main-config.nix
    ../../modules/sops.nix
    ../../modules/bare.nix
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
        eth0 = FIREWALL_PORTS;
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
  users.users.ascii.uid = lib.mkForce 1001;
  # https://github.com/nix-community/srvos/blob/885d705a55f5a9bd5a85cb6869358a1e5c522009/nixos/server/default.nix#L62-L93
  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
