{
  config,
  pkgs,
  inputs,
  lib,
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
  age.secrets.omni-etcd = {
    file = inputs.self.outPath + "/encrypt/omni/etcd.asc.age";
    mode = "0600";
    owner = config.users.users.omni.name;
    group = config.users.groups.omni.name;
  };

  users.groups.omni = {
    name = "omni";
    gid = 917; # I setup UID/GID manually since I refer to those later
  };

  users.users.omni = {
    group = "omni";
    uid = 1917;
    linger = true;
    isNormalUser = true;
    description = "Omni Controller";
    extraGroups = [ "podman" ];
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

  nix.settings.allowed-users = [ "omni" ];

  services.nginx.virtualHosts = {
    "omni-web" = {
      serverName = "omni.danu-01.adrp.xyz";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        extraConfig = ''
          proxy_redirect      off;
          proxy_http_version  1.1;
          proxy_set_header    Upgrade $http_upgrade;
          proxy_set_header    Connection $connection_upgrade;
          grpc_pass           grpc://127.0.0.1:8080;
        '';
      };
      addSSL = lib.mkIf config.ascii.system.cache.ssl.enable true;
      sslTrustedCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.fullchain;
      sslCertificateKey = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.key;
      sslCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.cert;
      listen = lib.mkIf config.ascii.system.cache.ssl.enable [
        {
          inherit (config.ascii.system.cache.ssl) port;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];
    };
    "omni-api" = {
      serverName = "api.danu-01.adrp.xyz";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8090";
        extraConfig = ''
          proxy_redirect      off;
          grpc_pass           grpc://127.0.0.1:8090;
        '';
      };
      addSSL = lib.mkIf config.ascii.system.cache.ssl.enable true;
      sslTrustedCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.fullchain;
      sslCertificateKey = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.key;
      sslCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.cert;
      listen = lib.mkIf config.ascii.system.cache.ssl.enable [
        {
          inherit (config.ascii.system.cache.ssl) port;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];
    };
    "omni-k8s" = {
      serverName = "kube.danu-01.adrp.xyz";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8100";
        extraConfig = ''
          proxy_redirect      off;
          proxy_pass          http://127.0.0.1:8100;
          proxy_http_version  1.1;
          proxy_set_header    Upgrade $http_upgrade;
          proxy_set_header    Connection $connection_upgrade;
        '';
      };
      addSSL = lib.mkIf config.ascii.system.cache.ssl.enable true;
      sslTrustedCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.fullchain;
      sslCertificateKey = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.key;
      sslCertificate = lib.mkIf config.ascii.system.cache.ssl.enable config.ascii.system.cache.ssl.cert;
      listen = lib.mkIf config.ascii.system.cache.ssl.enable [
        {
          inherit (config.ascii.system.cache.ssl) port;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    ''v "${config.users.users.omni.home}/omni"      0770 omni omni''
    ''v "${config.users.users.omni.home}/omni/etcd" 0770 omni omni''
  ];

  home-manager.users.omni =
    { pkgs, ... }:
    {
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

          if [ -d ${config.users.users.omni.home}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
            . "${config.users.users.omni.home}/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi
        '';
      };

      services.podman = {
        enable = true;
        autoUpdate.enable = true;
      };

      systemd.user.services.podman-pod-omni = {
        Unit = {
          Description = "Start podman 'omni' pod";
          Wants = [ "network-online.target" ];
          Requires = [ ];
          After = [ "network-online.target" ];
        };
        Install.WantedBy = [ ];
        Service = {
          Type = "forking";
          ExecStartPre = [
            # This is needed for the Pod start automatically
            "${pkgs.coreutils}/bin/sleep 3s"
            ''
              -${pkgs.podman}/bin/podman pod create \
                --replace \
                --userns=host \
                omni
            ''
          ];
          ExecStart = "${pkgs.podman}/bin/podman pod start omni";
          ExecStop = "${pkgs.podman}/bin/podman pod stop omni";
          RestartSec = "1s";
        };
      };
      services.podman.containers = {
        omni-talos = {
          image = "ghcr.io/siderolabs/omni:v0.47.1";
          description = "Start Omni (podman)";

          labels.PODMAN_SYSTEMD_UNIT = "podman-pod-omni.service";

          extraConfig = {
            Unit = {
              Wants = [ "network-online.target" ];
              Requires = [
                "podman-pod-omni.service"
              ];
              After = [
                "network-online.target"
                "podman-pod-omni.service"
              ];
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };

          exec = ''
            --account-id="0ee79fa5-9387-4b31-aa53-d5e1a5f54384" \
            --name=omni \
            --private-key-source=file:///certs/omni.asc \
            --event-sink-port=8091 \
            --bind-addr=127.0.0.1:8080 \
            --advertised-api-url=https://omni.danu-01.adrp.xyz:443/ \
            --machine-api-bind-addr=127.0.0.1:8090 \
            --siderolink-api-advertised-url=https://api.danu-01.adrp.xyz:443 \
            --k8s-proxy-bind-addr=127.0.0.1:8100 \
            --advertised-kubernetes-proxy-url=https://kube.danu-01.adrp.xyz:443 \
            --siderolink-wireguard-advertised-addr=omni.danu-01.adrp.xyz:50180 \
            --auth-auth0-enabled=false \
            --auth-saml-enabled \
            --auth-saml-url "https://keycloak.danu-01.adrp.xyz/realms/omni/protocol/saml/descriptor"
          '';

          autoStart = true;
          autoUpdate = "registry";
          extraPodmanArgs = [
            "--net=host"
            "--cap-add=NET_ADMIN"
            "--pod=omni"
            "--group-add=keep-groups"
          ];

          volumes = [
            "${config.users.users.omni.home}/omni/etcd:/_out/etcd"
            "${config.age.secrets.omni-etcd.path}:/certs/omni.asc:ro"
          ];
        };
      };
      home.stateVersion = "24.11";
    };
}
