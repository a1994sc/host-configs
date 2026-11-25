{
  config,
  lib,
  ...
}:
let
  cfg = config.ascii.system.dns;
in
{
  options.ascii.system.dns = {
    enable = lib.mkEnableOption "dns";
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
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
        bootstrapDns = "tcp+udp:1.1.1.1";
        caching = {
          minTime = "1m";
          prefetching = true;
        };
        connectIPVersion = "v4";
        filtering.queryTypes = [ "AAAA" ];
        hostsFile = {
          sources = [
            "/etc/hosts"
          ];
          hostsTTL = "360s";
          refreshPeriod = "1h";
          filterLoopback = true;
          loading.strategy = "fast";
        };
        log = {
          level = "info";
          format = "text";
          timestamp = true;
          privacy = false;
        };
        ports.dns = 53;
        prometheus.enable = false;
        upstreams = {
          init.strategy = "blocking";
          groups.default = [
            "tcp-tls:1.1.1.2:853"
            "tcp-tls:1.0.0.2:853"
          ];
          timeout = "2s";
        };
        # keep-sorted end
      };
    };

    # blocky owns 0.0.0.0:53, which collides with the resolved stub listener
    services.resolved.enable = false;

    boot.kernel.sysctl."net.core.rmem_max" = 1048576;
  };
}
