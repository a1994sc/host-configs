{ pkgs, config, ... }:
{
  services.keycloak = {
    enable = true;
    package = pkgs.keycloak;
    settings = {
      hostname = "keycloak.danu-01.adrp.xyz";
      hostname-strict-backchannel = true;
      http-port = 8080;
      http-enabled = true;
      http-relative-path = "/";
      proxy-headers = "xforwarded";
      hostname-strict = false;
      hostname-strict-https = false;
    };
    database = {
      inherit (config.services.postgresql) port;
      type = "postgresql";
      name = "keycloak";
      host = "localhost";
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
      proxyPass = "localhost:8080";
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
