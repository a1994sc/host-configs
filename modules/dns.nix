{
  config,
  lib,
  inputs,
  system,
  ...
}:
let
  cfg = config.ascii.system.dns;
in
{
  options.ascii.system.dns = with lib; {
    enable = mkEnableOption "dns";
    port = lib.mkOption {
      type = lib.types.ints.u16;
      default = 8153;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      blocky.enable = true;
      blocky.settings = {
        # keep-sorted start block=yes case=no
        blocking = {
          # keep-sorted start block=yes case=no
          blackLists.ads = [
            # https://firebog.net/
            # suspicious
            "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
            # Advertising
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Admiral.txt"
            # Tracking
            "https://v.firebog.net/hosts/Easyprivacy.txt"
            "https://v.firebog.net/hosts/Prigent-Ads.txt"
            # Malicious
            "https://v.firebog.net/hosts/Prigent-Crypto.txt"
            "https://v.firebog.net/hosts/RPiList-Malware.txt"
          ];
          blockTTL = "1m";
          blockType = "zeroIp";
          clientGroupsBlock.default = [ "ads" ];
          loading = {
            strategy = "blocking";
            refreshPeriod = "4h";
            downloads = {
              attempts = 5;
              timeout = "4m";
              cooldown = "10s";
            };
          };
          # keep-sorted end
        };
        bootstrapDns = "1.1.1.1";
        connectIPVersion = "dual";
        filtering.queryTypes = [ "AAAA" ];
        log = {
          level = "info";
          format = "text";
          timestamp = true;
          privacy = false;
        };
        minTlsServeVersion = "1.3";
        ports.dns = cfg.port + 1;
        prometheus.enable = false;
        upstreams = {
          init.strategy = "blocking";
          groups.default = [ "127.0.0.1:${builtins.toString (cfg.port + 2)}" ];
          timeout = "2s";
        };
        # keep-sorted end
      };

      coredns = {
        enable = true;
        package = inputs.ascii-pkgs.packages.${system}.coredns;
        config = ''
          barb-neon.ts.net:53 {
            bind eth0
            forward . 100.100.100.100
          }

          .:53 {
            bind eth0
            log
            forward . 127.0.0.1:${builtins.toString (cfg.port + 1)}
            errors
            cache
          }

          adrp.xyz:53 {
            bind eth0
            hosts
            log
          }
        '';
      };

      unbound.enable = true;
      unbound.resolveLocalQueries = false;
      unbound.settings.server = {
        # keep-sorted start block=yes case=no
        do-ip4 = "yes";
        do-ip6 = "no";
        do-tcp = "yes";
        do-udp = "yes";
        edns-buffer-size = 1232;
        harden-dnssec-stripped = "yes";
        harden-glue = "yes";
        interface = "127.0.0.1";
        num-threads = 1;
        port = cfg.port + 2;
        prefer-ip6 = "no";
        prefetch = "yes";
        private-address = [
          # keep-sorted start
          "10.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "fd00::/8"
          "fe80::/10"
          # keep-sorted end
        ];
        so-rcvbuf = "1m";
        use-caps-for-id = "no";
        verbosity = 0;
        # keep-sorted end
      };
    };

    systemd.services.coredns.before = [ "unbound.service" ];
    systemd.services.unbound.before = [ "blocky.service" ];

    boot.kernel.sysctl = {
      "net.core.rmem_max" = 1048576;
    };
  };
}
