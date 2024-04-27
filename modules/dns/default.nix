{
  config,
  pkgs,
  lib,
  ...
}:
{
  services = {
    blocky.enable = true;
    blocky.settings = {
      upstream.default = [ "127.0.0.1:8155" ]; # Deprecated
      bootstrapDns = "1.1.1.1";
      upstreamTimeout = "2s"; # Deprecated
      startVerifyUpstream = true;
      connectIPVersion = "dual";
      minTlsServeVersion = "1.3";
      blocking = {
        blackLists.ads = [
          "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
          "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
          "https://v.firebog.net/hosts/AdguardDNS.txt"
          "https://v.firebog.net/hosts/Easyprivacy.txt"
          "https://v.firebog.net/hosts/Prigent-Ads.txt"
          "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
          "https://phishing.army/download/phishing_army_blocklist_extended.txt"
        ];
        clientGroupsBlock.default = [ "ads" ];
        blockType = "zeroIp";
        blockTTL = "1m";
        refreshPeriod = "4h";
        downloadTimeout = "4m"; # Deprecated
        downloadAttempts = 5; # Deprecated
        downloadCooldown = "10s"; # Deprecated
        startStrategy = "blocking"; # Deprecated
      };

      prometheus.enable = false;
      filtering.queryTypes = [ "AAAA" ];
      ports.dns = 8153;

      log = {
        level = "info";
        format = "text";
        timestamp = true;
        privacy = false;
      };
    };

    dnsdist = {
      enable = true;
      listenPort = 53;
      listenAddress = "0.0.0.0";
      extraConfig = ''
        setACL({'0.0.0.0/0'})
        truncateTC(true)
        newServer("127.0.0.1:8153")
        newServer({address="127.0.0.1:8154", pool="lab"})
        addAction({'example.io.', 'adrp.xyz.', '10.in-addr.arpa.'}, PoolAction("lab"))
        setSecurityPollSuffix("")
      '';
    };

    unbound.enable = true;
    unbound.resolveLocalQueries = false;
    unbound.settings = {
      server = {
        verbosity = 0;
        interface = "127.0.0.1";
        port = 8155;
        do-ip4 = "yes";
        do-ip6 = "no";
        do-udp = "yes";
        do-tcp = "yes";
        prefer-ip6 = "no";
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        use-caps-for-id = "no";
        edns-buffer-size = 1232;
        prefetch = "yes";
        num-threads = 1;
        so-rcvbuf = "1m";
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
        ];
      };
    };
  };

  systemd.services.dnsdist.before = [ "unbound.service" ];
  systemd.services.unbound.before = [ "blocky.service" ];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 1048576;
  };
}
