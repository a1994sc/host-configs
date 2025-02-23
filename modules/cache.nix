{
  lib,
  config,
  ...
}:
let
  cfg = config.ascii.system.cache;
in
{
  options.ascii.system.cache = {
    enable = lib.mkEnableOption "nix";
    domain = lib.mkOption {
      type = lib.types.str;
    };
    priority = lib.mkOption {
      type = lib.types.str;
      default = "30";
      description = ''
        Set Priority of Nix cache. Remeber that a lower number gives higher priorty!
        For reference, cache.nixos.org has a priority of 40.
      '';
    };
    cacheDomain = lib.mkOption {
      type = lib.types.str;
      default = "https://cache.nixos.org";
    };
    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/nginx/nix";
    };
    maxCacheSize = lib.mkOption {
      type = lib.types.str;
      default = "350G";
    };
    maxCacheAge = lib.mkOption {
      type = lib.types.str;
      default = "180d";
    };
    sans = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    alts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (_sub: {
          options = {
            url = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            key = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
          };
        })
      );
      default = { };
    };
    ssl = {
      enable = lib.mkEnableOption "ssl";
      cert = lib.mkOption {
        type = lib.types.str;
        default = "/var/cache/nginx/cert.pem";
      };
      key = lib.mkOption {
        type = lib.types.str;
        default = "/var/cache/nginx/key.pem";
      };
      fullchain = lib.mkOption {
        type = lib.types.str;
        default = "/var/cache/nginx/fullchain.pem";
      };
      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 443;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.stringLength cfg.domain > 0;
        message = "Must provide a domain name";
      }
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.cacheDir} 0755 nginx nginx - -"
    ];

    fileSystems = {
      "/run/nginx/cache/nix" = {
        options = [ "bind" ];
        device = "${cfg.cacheDir}";
      };
    };

    nix.settings.trusted-public-keys = builtins.map (alt: cfg.alts.${alt}.key) (
      builtins.attrNames cfg.alts
    );

    services.nginx = {
      enable = true;
      appendHttpConfig = ''
        proxy_cache_path /run/nginx/cache/nix levels=1:2 keys_zone=nix_cache_zone:50m max_size=${cfg.maxCacheSize} inactive=${cfg.maxCacheAge};
      '';

      virtualHosts =
        {
          "cache-${cfg.domain}" = {
            serverName = cfg.domain;
            extraConfig = ''
              proxy_cache nix_cache_zone;
              proxy_cache_valid 200 ${cfg.maxCacheAge};
              proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
              proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie Vary;
              proxy_ssl_server_name on;
              proxy_ssl_verify on;
              proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
              resolver 1.1.1.2 ipv6=off;
            '';

            locations = {
              "/" = {
                proxyPass = cfg.cacheDomain;
                extraConfig = ''
                  proxy_send_timeout 300ms;
                  proxy_connect_timeout 300ms;

                  error_page 502 504 =404 @fallback;

                  proxy_set_header Host $proxy_host;
                '';
              };
              "/nix-cache-info" = {
                extraConfig = ''
                  return 200 "StoreDir: /nix/store\nWantMassQuery: 1\n";
                '';
              };
              "@fallback" = {
                extraConfig = ''
                  return 200 "404";
                '';
              };
            };

            addSSL = lib.mkIf cfg.ssl.enable true;
            sslTrustedCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.fullchain;
            sslCertificateKey = lib.mkIf cfg.ssl.enable cfg.ssl.key;
            sslCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.cert;
            listen = lib.mkIf cfg.ssl.enable [
              {
                inherit (cfg.ssl) port;
                addr = "0.0.0.0";
                ssl = true;
              }
            ];
          };
        }
        // builtins.listToAttrs (
          builtins.map (san: {
            name = "cache-${san}";
            value = {
              serverName = san;
              extraConfig = ''
                proxy_cache nix_cache_zone;
                proxy_cache_valid 200 ${cfg.maxCacheAge};
                proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
                proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie Vary;
                proxy_ssl_server_name on;
                proxy_ssl_verify on;
                proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
                resolver 1.1.1.2 ipv6=off;
              '';

              locations = {
                "/" = {
                  proxyPass = cfg.cacheDomain;
                  extraConfig = ''
                    proxy_send_timeout 300ms;
                    proxy_connect_timeout 300ms;

                    error_page 502 504 =404 @fallback;

                    proxy_set_header Host $proxy_host;
                  '';
                };
                "/nix-cache-info" = {
                  extraConfig = ''
                    return 200 "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: ${cfg.priority}\n";
                  '';
                };
                "@fallback" = {
                  extraConfig = ''
                    return 200 "404";
                  '';
                };
              };
              addSSL = lib.mkIf cfg.ssl.enable true;
              sslTrustedCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.fullchain;
              sslCertificateKey = lib.mkIf cfg.ssl.enable cfg.ssl.key;
              sslCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.cert;
              listen = lib.mkIf cfg.ssl.enable [
                {
                  inherit (cfg.ssl) port;
                  addr = "0.0.0.0";
                  ssl = true;
                }
              ];
            };
          }) cfg.sans
        )
        // builtins.listToAttrs (
          builtins.map (alt: {
            name = "cache-alt-${alt}";
            value = {
              serverName = "${alt}.${cfg.domain}";
              extraConfig = ''
                proxy_cache nix_cache_zone;
                proxy_cache_valid 200 ${cfg.maxCacheAge};
                proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
                proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie Vary;
                proxy_ssl_server_name on;
                proxy_ssl_verify on;
                proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
                resolver 1.1.1.2 ipv6=off;
              '';

              locations = {
                "/" = {
                  proxyPass = cfg.alts.${alt}.url;
                  extraConfig = ''
                    proxy_send_timeout 300ms;
                    proxy_connect_timeout 300ms;

                    error_page 502 504 =404 @fallback;

                    proxy_set_header Host $proxy_host;
                  '';
                };
                "/nix-cache-info" = {
                  extraConfig = ''
                    return 200 "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: ${cfg.priority}\n";
                  '';
                };
                "@fallback" = {
                  extraConfig = ''
                    return 200 "404";
                  '';
                };
              };
              addSSL = lib.mkIf cfg.ssl.enable true;
              sslTrustedCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.fullchain;
              sslCertificateKey = lib.mkIf cfg.ssl.enable cfg.ssl.key;
              sslCertificate = lib.mkIf cfg.ssl.enable cfg.ssl.cert;
              listen = lib.mkIf cfg.ssl.enable [
                {
                  inherit (cfg.ssl) port;
                  addr = "0.0.0.0";
                  ssl = true;
                }
              ];
            };
          }) (builtins.attrNames cfg.alts)
        );
    };
  };
}
