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
  cert = pkgs.cacert.override {
    extraCertificateFiles = [
      (inputs.self.outPath + "/certs/derpy-bundle.crt")
    ];
  };
in
{
  age.secrets.omni-etcd = {
    file = inputs.self.outPath + "/encrypt/omni/etcd.asc.age";
    mode = "0600";
    owner = config.users.users.omni.name;
    group = config.users.groups.omni.name;
  };

  age.secrets.omni-bare-metal = {
    file = inputs.self.outPath + "/encrypt/omni/bare-metal.env.age";
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
    extraGroups = [
      "podman"
    ];
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

  virtualisation.oci-containers.containers.omni-talos = {
    autoStart = true;
    # renovate: datasource=docker
    image = "ghcr.io/siderolabs/omni:v0.50.1";
    hostname = "omni-talos";
    cmd = [
      "--account-id=\"0ee79fa5-9387-4b31-aa53-d5e1a5f54384\""
      "--name=omni"
      "--private-key-source=file:///certs/omni.asc"
      "--event-sink-port=8091"
      "--bind-addr=127.0.0.1:8087"
      "--advertised-api-url=https://omni.danu-01.adrp.xyz"
      "--machine-api-bind-addr=0.0.0.0:8090"
      "--siderolink-api-advertised-url=grpc://10.3.20.5:8090"
      "--k8s-proxy-bind-addr=127.0.0.1:8100"
      "--advertised-kubernetes-proxy-url=https://kube.danu-01.adrp.xyz"
      "--siderolink-wireguard-advertised-addr=10.3.20.5:50180"
      "--auth-auth0-enabled=false"
      "--auth-saml-enabled"
      "--auth-saml-url=https://keycloak.danu-01.adrp.xyz/realms/omni/protocol/saml/descriptor"
    ];
    volumes = [
      "${config.users.users.omni.home}/omni/etcd:/_out/etcd"
      "${config.age.secrets.omni-etcd.path}:/certs/omni.asc:ro"
      "${cert}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt:ro"
      "${cert}/etc/ssl/certs/ca-bundle.crt:/etc/pki/tls/certs/ca-bundle.crt:ro"
    ];
    extraOptions = [
      "--device=/dev/net/tun:/dev/net/tun"
      "--net=host"
      "--privileged=true"
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
    ];
  };

  virtualisation.oci-containers.containers.omni-bare-metal = {
    autoStart = true;
    # renovate: datasource=docker
    image = "ghcr.io/siderolabs/omni-infra-provider-bare-metal:v0.1.4";
    hostname = "omni-bare-metal";
    cmd = [
      "--api-advertise-address=10.3.20.5"
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
      "--privileged=true"
      "--cap-add=NET_RAW"
      "--cap-add=NET_ADMIN"
    ];
  };

  nix.settings.allowed-users = [ "omni" ];

  services.nginx.virtualHosts = {
    "omni-web" = {
      serverName = "omni.danu-01.adrp.xyz";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8087";
        extraConfig = ''
          proxy_redirect      off;
          proxy_http_version  1.1;
          proxy_set_header    Upgrade $http_upgrade;
          proxy_set_header    Connection $connection_upgrade;
          grpc_pass           grpc://127.0.0.1:8087;
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

  home-manager.users.omni = _: {
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
    home.stateVersion = "24.11";
  };
}
