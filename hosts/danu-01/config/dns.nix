{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  port = 8153;
in
{
  networking.nat.forwardPorts = [
    {
      destination = "127.0.0.1:${8153}";
      proto = "tcp";
      sourcePort = 53;
    }
    {
      destination = "127.0.0.1:${8153}";
      proto = "udp";
      sourcePort = 53;
    }
  ];
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
          # Malicious
          "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
          "https://phishing.army/download/phishing_army_blocklist_extended.txt"
          # Tracking
          "https://v.firebog.net/hosts/Easyprivacy.txt"
          "https://v.firebog.net/hosts/Prigent-Ads.txt"
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
      ports.dns = port + 1;
      prometheus.enable = false;
      upstreams = {
        init.strategy = "blocking";
        groups.default = [ "127.0.0.1:8155" ];
        timeout = "2s";
      };
      # keep-sorted end
    };

    coredns = {
      enable = true;
      package = inputs.ascii-pkgs.packages.${system}.coredns-records;
      config = ''
        barb-neon.ts.net:${builtins.toString port} {
          forward . 100.100.100.100
        }

        .:${port} {
          hosts
          forward . 127.0.0.1:${port + 1}
          errors
          cache
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
      port = port + 2;
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
}
