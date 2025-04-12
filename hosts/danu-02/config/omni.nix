{
  config,
  pkgs,
  inputs,
  ...
}:
let
  color = {
    magenta = "35";
    cyan = "36";
    white = "97";
  };
  font.reset = "0";
  escape = input: "\\[\\e[${input};11m\\]";
in
{
  users.groups.canister = {
    name = "canister";
    gid = 917;
  };

  users.users.canister = {
    group = "canister";
    uid = 1917;
    linger = true;
    isNormalUser = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      # keep-sorted start
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACa5MIyu4mLLLc0D5Y0eOWV1JnvvSo68pDJAh4SyC1WyMVK1eOIlpyDlfFNu7wev8fPELJEwbT+pCsjH2FVU8qRNAH17nW1EBn9xWOX7rEnpxOp6X485+jeA0t/a2jB6e7Bcn86Xwa1tPEbIKS6eo530KMLagaCFpl9arv1SGWeh6/YAw== aconlon@puck.adrp.xyz"
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF/R3bjaZYUB6cJe7jcexHc+n+zk+F+39SH55nHWk1uqX5h+/YSkDlDPl42QfVVcV/kyX21yv3zUO3zl6h+OsDltgH9+VggOJSvrYYWLx5vb9H3gH6y3yfc2V8Eyg6v4svSE2z6SbRmQw/bLmCcCU+C+oC74du/a/VJocT4ib706LMG2A== aconlon@omga.ardp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
      # keep-sorted end
    ];
  };

  virtualisation.oci-containers.containers.rootless-registry = {
    autoStart = true;
    image = "ghcr.io/distribution/distribution:3.0.0";
    hostname = "registry";
  };

  virtualisation.oci-containers.containers.omni-bare-metal =
    let
      cert = pkgs.cacert {
        extraCertificateFiles = [
          (inputs.self.outPath + "/certs/derpy-bundle.crt")
        ];
      };
    in
    {
      autoStart = true;
      image = "ghcr.io/siderolabs/omni-infra-provider-bare-metal:v0.1.3";
      hostname = "omni-bare-metal";
      cmd = [
        "--api-advertise-address=10.3.20.6"
      ];
      volumes = [
        "${cert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt:ro"
        "${cert}/etc/ssl/certs/ca-bundle.crt:/etc/pki/tls/certs/ca-bundle.crt:ro"
      ];
      environmentFiles = [
        config.age.secrets.omni-bare-metal.path
      ];
      extraOptions = [
        "--net=host"
      ];
    };

  nix.settings.allowed-users = [ "canister" ];

  systemd.services.docker-rootless-registry = {
    enable = true;
    environment.DOCKER_HOST = "unix:///run/user/${toString config.users.users.canister.uid}/docker.sock";
    serviceConfig.User = "${config.users.users.canister.name}";
  };

  systemd.services.omni-bare-metal = {
    enable = true;
    environment.DOCKER_HOST = "unix:///run/user/${toString config.users.users.canister.uid}/docker.sock";
    serviceConfig.User = "${config.users.users.canister.name}";
  };

  systemd.tmpfiles.rules = [
    ''v "${config.users.users.canister.home}/canister"      0770 canister canister''
  ];

  home-manager.users.canister = _: {
    manual.manpages.enable = false;
    nixpkgs.config.allowUnfree = true;
    news.display = "silent";
    xdg.enable = true;

    programs.bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        PS1="${escape color.magenta}\u${escape color.white}@\h:${escape color.cyan}[\w]: ${escape font.reset}"

        export PS1

        if [ -d ${config.users.users.canister.home}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
          . "${config.users.users.canister.home}/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '';
    };
    home.stateVersion = "24.11";
  };
}
