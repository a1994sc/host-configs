{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  age.secrets.keycloak-database = {
    file = inputs.self.outPath + "/encrypt/keycloak/base.word.age";
    mode = "0600";
  };

  services.keycloak = {
    enable = true;
    package = pkgs.keycloak;
    settings = {
      hostname = "https://keycloak.danu-01.adrp.xyz";
      hostname-backchannel-dynamic = true;
      http-port = 8080;
      https-port = 8443;
      http-enabled = true;
      http-relative-path = "/";
      proxy-headers = "xforwarded";
      hostname-strict = false;
      hostname-strict-https = false;
      bootstrap-admin-username = "temp-admin";
      bootstrap-admin-password = "changeme";
    };
    database = {
      inherit (config.services.postgresql.settings) port;
      type = "postgresql";
      name = "keycloak";
      host = "localhost";
      passwordFile = "${config.age.secrets.keycloak-database.path}";
    };
  };

  services.postgresql.package = pkgs.postgresql;

  systemd.services.postgresql = {
    before = [ "keycloak.service" ];
  };

  services.nginx.virtualHosts."keycloak-proxy" = {
    serverName = "keycloak.danu-01.adrp.xyz";
    extraConfig = ''
      set_real_ip_from 0.0.0.0/0;
      real_ip_header X-Real-IP;
      real_ip_recursive on;
    '';
    locations."/" = {
      proxyPass = "http://localhost:${builtins.toString config.services.keycloak.settings.http-port}";
      extraConfig = ''
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port 443;
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
}
