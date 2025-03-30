{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    firewall.enable = true;
    hostName = "puck"; # Define your hostname.
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    nameservers = [
      "100.100.100.100" # magic dns, tailscale
      "10.3.10.5" # adrp.xyz, primary
      "10.3.10.6" # adrp.xyz, replica
      "9.9.9.9" # fallback, clear web
    ];
    hosts = {
      "10.3.10.5" = [
        "danu-01.adrp.xyz"
        "keycloak.danu-01.adrp.xyz"
      ] ++ (builtins.map (alt: "${alt}.${danu-01.domain}") (builtins.attrNames danu-01.alts));
      "10.3.10.6" = [
        "danu-02.adrp.xyz"
      ] ++ (builtins.map (alt: "${alt}.${danu-02.domain}") (builtins.attrNames danu-02.alts));
    };
  };

  nix.settings.substituters =
    [
      "https://${danu-01.domain}?priority=10"
      "https://${danu-02.domain}?priority=10"
    ]
    ++ (builtins.map (alt: "https://${alt}.${danu-01.domain}?priority=15") (
      builtins.attrNames danu-01.alts
    ))
    ++ (builtins.map (alt: "https://${alt}.${danu-02.domain}?priority=10") (
      builtins.attrNames danu-02.alts
    ));

  nix.settings.trusted-public-keys = lib.lists.unique (
    (builtins.map (alt: danu-01.alts.${alt}.key) (builtins.attrNames danu-01.alts))
    ++ (builtins.map (alt: danu-02.alts.${alt}.key) (builtins.attrNames danu-02.alts))
  );

  services = {
    # keep-sorted start block=yes case=no
    resolved = {
      enable = true;
      domains = [
        "adrp.xyz"
        "barb-neon.ts.net"
      ];
    };
    tailscale = {
      enable = true;
      port = 0;
      useRoutingFeatures = "client";
      package = pkgs.unstable.tailscale;
      permitCertUid = "1000";
      extraUpFlags = [
        "--operator=${config.users.users.ascii.name}"
        "--accept-routes=true"
      ];
    };
    # keep-sorted end
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}
