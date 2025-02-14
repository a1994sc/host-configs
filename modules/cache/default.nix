{ lib, config, ... }:
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

    services.nginx = {
      enable = true;
      appendHttpConfig = ''
        proxy_cache_path /run/nginx/cache/nix levels=1:2 keys_zone=nix_cache_zone:50m max_size=${cfg.maxCacheSize} inactive=${cfg.maxCacheAge};
      '';

      virtualHosts."${cfg.domain}" = {
        extraConfig = ''
          proxy_cache nix_cache_zone;
          proxy_cache_valid 200 ${cfg.maxCacheAge};
          proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
          proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie Vary;
          proxy_ssl_server_name on;
          proxy_ssl_verify on;
          proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
          set $upstream_endpoint https://cache.nixos.org;
        '';
        locations."/" = {
          proxyPass = "$upstream_endpoint";
          extraConfig = ''
            proxy_send_timeout 300ms;
            proxy_connect_timeout 300ms;

            error_page 502 504 =404 @fallback;

            proxy_set_header Host $proxy_host;
          '';
        };

        locations."/nix-cache-info" = {
          extraConfig = ''
            return 200 "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: ${cfg.priority}\n";
          '';
        };

        locations."@fallback" = {
          extraConfig = ''
            return 200 "404";
          '';
        };
      };
    };
  };
}
