_: {
  services = {
    blocky.enable = true;
    blocky.settings = {
      # keep-sorted start block=yes case=no
      blocking = {
        # keep-sorted start block=yes case=no
        blackLists.ads = [
          "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
          "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
          "https://v.firebog.net/hosts/AdguardDNS.txt"
          "https://v.firebog.net/hosts/Easyprivacy.txt"
          "https://v.firebog.net/hosts/Prigent-Ads.txt"
          "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
          "https://phishing.army/download/phishing_army_blocklist_extended.txt"
        ];
        blockTTL = "1m";
        blockType = "zeroIp";
        clientGroupsBlock.default = [ "ads" ];
        downloadAttempts = 5; # Deprecated
        downloadCooldown = "10s"; # Deprecated
        downloadTimeout = "4m"; # Deprecated
        refreshPeriod = "4h";
        startStrategy = "blocking"; # Deprecated
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
      ports.dns = 8153;
      prometheus.enable = false;
      startVerifyUpstream = true;
      upstream.default = [ "127.0.0.1:8155" ]; # Deprecated
      upstreamTimeout = "2s"; # Deprecated
      # keep-sorted end
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
      port = 8155;
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

  systemd.services.dnsdist.before = [ "unbound.service" ];
  systemd.services.unbound.before = [ "blocky.service" ];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 1048576;
  };
}
