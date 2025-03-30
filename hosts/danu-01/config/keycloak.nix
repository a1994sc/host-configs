{
  pkgs,
  config,
  inputs,
  ...
}:
{
  age.secrets.keycloak-database = {
    file = inputs.self.outPath + "/encrypt/keycloak/base.word.age";
    mode = "0600";
  };

  services.keycloak = {
    enable = false;
    package = pkgs.keycloak;
    settings = {
      hostname = "keycloak.danu-01.adrp.xyz";
      hostname-backchannel-dynamic = true;
      http-port = 8080;
      http-enabled = true;
      http-relative-path = "/";
      proxy-headers = "xforwarded";
      hostname-strict = false;
      hostname-strict-https = false;
    };
    database = {
      inherit (config.services.postgresql.settings) port;
      type = "postgresql";
      name = "keycloak";
      host = "localhost";
      passwordFile = "${config.age.secrets.keycloak-database.path}";
    };
  };

  services.postgresql = {
    settings.port = 3306;
    package = pkgs.postgresql;
  };

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
  };
}
