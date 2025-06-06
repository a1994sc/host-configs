{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii;
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
      "100.89.86.119" =
        [
          "danu-01.adrp.xyz"
        ]
        ++ (lib.lists.unique (
          (builtins.filter (name: builtins.match ".*\\.xyz" name != null) danu-01.security.certs.sans)
          ++ (builtins.map (alt: "${alt}.${danu-01.system.cache.domain}") (
            builtins.attrNames danu-01.system.cache.alts
          ))
        ));
      "100.126.110.27" =
        [
          "danu-02.adrp.xyz"
        ]
        ++ (lib.lists.unique (
          (builtins.filter (name: builtins.match ".*\\.xyz" name != null) danu-02.security.certs.sans)
          ++ (builtins.map (alt: "${alt}.${danu-02.system.cache.domain}") (
            builtins.attrNames danu-02.system.cache.alts
          ))
        ));
    };
  };

  nix.settings.substituters =
    [
      "https://${danu-01.system.cache.domain}?priority=10"
      "https://${danu-02.system.cache.domain}?priority=10"
    ]
    ++ (builtins.map (alt: "https://${alt}.${danu-01.system.cache.domain}?priority=15") (
      builtins.attrNames danu-01.system.cache.alts
    ))
    ++ (builtins.map (alt: "https://${alt}.${danu-02.system.cache.domain}?priority=10") (
      builtins.attrNames danu-02.system.cache.alts
    ));

  nix.settings.trusted-public-keys = lib.lists.unique (
    (builtins.map (alt: danu-01.system.cache.alts.${alt}.key) (
      builtins.attrNames danu-01.system.cache.alts
    ))
    ++ (builtins.map (alt: danu-02.system.cache.alts.${alt}.key) (
      builtins.attrNames danu-02.system.cache.alts
    ))
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
