{ config, pkgs, ... }:
{
  programs.bash.enableCompletion = true;

  networking = {
    domain = "adrp.xyz";
    search = [ "adrp.xyz" ];
    wireless.enable = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    firewall.enable = false;
  };

  services.xserver.enable = false;

  nixpkgs.overlays = [
    (_final: prev: {
      nh = prev.nh.overrideAttrs (oldAttrs: {
        patches = oldAttrs.patches ++ [
          (prev.fetchpatch2 {
            url = "https://github.com/PaulGrandperrin/nh-root/commit/bea0ce26e4b1a260e285164c49456d70d346c924.patch"; # don't bail when non-root
            hash = "sha256-w8/nfMkk/CeOaLW2XIUvKs7//bGm11Cj6ifyTYzlqjo=";
          })
        ];
      });
    })
  ];

  environment.systemPackages = with pkgs; [ nh ];

  users = {
    groups.custodian = {
      gid = 1500;
      name = "custodian";
    };
    users.custodian = {
      uid = 1500;
      group = config.users.groups.custodian.name;
      linger = true;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "dialout"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF/R3bjaZYUB6cJe7jcexHc+n+zk+F+39SH55nHWk1uqX5h+/YSkDlDPl42QfVVcV/kyX21yv3zUO3zl6h+OsDltgH9+VggOJSvrYYWLx5vb9H3gH6y3yfc2V8Eyg6v4svSE2z6SbRmQw/bLmCcCU+C+oC74du/a/VJocT4ib706LMG2A== aconlon@omga.ardp.xyz"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACa5MIyu4mLLLc0D5Y0eOWV1JnvvSo68pDJAh4SyC1WyMVK1eOIlpyDlfFNu7wev8fPELJEwbT+pCsjH2FVU8qRNAH17nW1EBn9xWOX7rEnpxOp6X485+jeA0t/a2jB6e7Bcn86Xwa1tPEbIKS6eo530KMLagaCFpl9arv1SGWeh6/YAw== aconlon@puck.adrp.xyz"
      ];
    };
  };
}
