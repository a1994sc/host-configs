{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../modules
    ../../modules/dns
  ];

  nix.gc.dates = "Thur 02:00";
  system.autoUpgrade.dates = "Thur 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  networking = {
    hostName = "menrva";
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
          # address = "10.3.10.5";
          address = "10.3.10.9";
          prefixLength = 24;
        }
      ];
      "br0".ipv4.addresses = [
        {
          address = "192.168.100.3";
          prefixLength = 24;
        }
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eth0";
    };
  };
  # containers.sshbox =
  #   let
  #     ip =
  #       let
  #         eth = builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0;
  #       in
  #       eth.address;
  #   in
  #   {
  #     hostAddress = ip;
  #     localAddress = "10.3.10.19/24";
  #     privateNetwork = true;
  #     autoStart = true;
  #     config = _: {
  #       services.openssh.enable = true;
  #       services.resolved.enable = true;
  #       networking = {
  #         firewall = {
  #           enable = true;
  #           allowedTCPPorts = [ 22 ];
  #         };
  #         # Use systemd-resolved inside the container
  #         # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
  #         useHostResolvConf = lib.mkForce false;
  #       };
  #       system.stateVersion = "24.05";
  #       users.users.root.openssh.authorizedKeys.keys = [
  #         # keep-sorted start
  #         "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACa5MIyu4mLLLc0D5Y0eOWV1JnvvSo68pDJAh4SyC1WyMVK1eOIlpyDlfFNu7wev8fPELJEwbT+pCsjH2FVU8qRNAH17nW1EBn9xWOX7rEnpxOp6X485+jeA0t/a2jB6e7Bcn86Xwa1tPEbIKS6eo530KMLagaCFpl9arv1SGWeh6/YAw== aconlon@puck.adrp.xyz"
  #         "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF/R3bjaZYUB6cJe7jcexHc+n+zk+F+39SH55nHWk1uqX5h+/YSkDlDPl42QfVVcV/kyX21yv3zUO3zl6h+OsDltgH9+VggOJSvrYYWLx5vb9H3gH6y3yfc2V8Eyg6v4svSE2z6SbRmQw/bLmCcCU+C+oC74du/a/VJocT4ib706LMG2A== aconlon@omga.ardp.xyz"
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
  #         # keep-sorted end
  #       ];
  #     };
  #   };
}
