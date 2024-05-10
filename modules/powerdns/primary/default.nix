{
  config,
  pkgs,
  lib,
  ...
}:
let
  db_user = "powerdns";
  db_tabl = "powerdns";
in
{
  sops.secrets = {
    rep-user = {
      sopsFile = ../../../secrets/dns/powerdns-primary.yml;
      mode = "0600";
    };
    primary-env = {
      sopsFile = ../../../secrets/dns/powerdns-primary.yml;
      mode = "0600";
    };
    tls-crt = {
      owner = "${config.services.nginx.user}";
      group = "${config.services.nginx.group}";
      sopsFile = ../../../secrets/dns/dns1.yml;
      mode = "0600";
    };
    tls-key = {
      owner = "${config.services.nginx.user}";
      group = "${config.services.nginx.group}";
      sopsFile = ../../../secrets/dns/dns1.yml;
      mode = "0600";
    };
  };

  services.postgresql = {
    enable = true;
    port = 3306;
    package = pkgs.postgresql_15;
    dataDir = "/var/lib/postgresql";
    enableTCPIP = true;
    settings = {
      wal_level = "logical";
      wal_log_hints = "on";
      max_wal_senders = "8";
      max_wal_size = "1GB";
      hot_standby = "on";
    };
    ensureDatabases = [ "${db_tabl}" ];
    authentication = lib.mkForce ''
      local  all          all                         trust
      host   all          all           127.0.0.1/32  trust
      host   all          all           ::1/128       trust
      local  replication  all                         trust
      host   replication  all           127.0.0.1/32  trust
      host   replication  all           ::1/128       trust
      host   replication  powerdns_rep  10.3.10.1/24  md5
    '';
  };

  systemd.services.postgresql = {
    before = [ "pdns.service" ];
  };

  services.powerdns = {
    enable = true;
    secretFile = "/run/secrets/primary-env";
    extraConfig = ''
      launch=gpgsql
      gpgsql-host=localhost
      gpgsql-port=3306
      gpgsql-user=${db_user}
      gpgsql-dbname=${db_user}
      gpgsql-password=$POWERDNS_MYSQL_PASS
      primary=yes
      api=yes
      api-key=$POWERDNS_API_PASS
      webserver=yes
      webserver-allow-from=127.0.0.1,10.0.0.0/8
      webserver-address=0.0.0.0
      webserver-password=$POWERDNS_WEB_PASS
      version-string=anonymous
      default-ttl=1500
      allow-notify-from=0.0.0.0
      allow-axfr-ips=127.0.0.1
      local-port=8154
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "ip" = {
        addSSL = true;
        sslCertificate = config.sops.secrets.tls-crt.path;
        sslCertificateKey = config.sops.secrets.tls-key.path;
        serverName = "10.3.10.5";
        listen = [
          {
            port = 8443;
            addr = "0.0.0.0";
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8081/";
        };
      };
      "machine" = {
        addSSL = true;
        sslCertificate = config.sops.secrets.tls-crt.path;
        sslCertificateKey = config.sops.secrets.tls-key.path;
        serverName = "10.3.20.5";
        listen = [
          {
            port = 8443;
            addr = "0.0.0.0";
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8081/";
        };
      };
      "dns1" = {
        addSSL = true;
        sslCertificate = config.sops.secrets.tls-crt.path;
        sslCertificateKey = config.sops.secrets.tls-key.path;
        serverName = "dns1.adrp.xyz";
        listen = [
          {
            port = 8443;
            addr = "0.0.0.0";
            ssl = true;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8081/";
        };
      };
    };
  };
}
