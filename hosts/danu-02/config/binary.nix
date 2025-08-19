{
  inputs,
  pkgs,
  config,
  ...
}:
{
  age.secrets.binary = {
    file = inputs.self.outPath + "/encrypt/binary/${config.networking.hostName}.key.age";
    mode = "0600";
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.binary.path;
  };

  # security.sudo.extraRules = [
  #   {
  #     users = [ "acme" ];
  #     groups = [ "acme" ];
  #     commands = [
  #       {
  #         command = "${tailcerts}/bin/tailcerts";
  #         options = [
  #           "SETENV"
  #           "NOPASSWD"
  #         ];
  #       }
  #     ];
  #   }
  # ];

  # systemd.services.tailscale-certs =
  #   let
  #     acme = pkgs.writeShellScriptBin "tailscale-certs.sh" ''
  #       /run/wrappers/bin/sudo ${tailcerts}/bin/tailcerts
  #     '';
  #   in
  #   {
  #     serviceConfig = {
  #       Type = "oneshot";
  #       User = "${config.users.users.acme.name}";
  #     };
  #     script = "${acme}/bin/tailscale-certs.sh";
  #   };

  # systemd.timers.tailscale-certs = {
  #   enable = true;
  #   wantedBy = [ "timers.target" ];
  #   partOf = [ "tailscale-certs.service" ];
  #   timerConfig = {
  #     OnCalendar = "*-*-01 02:00:00";
  #     Unit = "tailscale-certs.service";
  #   };
  # };

  # services.nginx.virtualHosts."binary-cache-${config.ascii.system.cache.domain}" = {
  #   serverName = "${config.networking.hostName}.barb-neon.ts.net";
  #   locations."/".proxyPass =
  #     "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";

  #   addSSL = true;
  #   sslCertificateKey = "/var/cache/nginx/tailcale-key.pem";
  #   sslCertificate = "/var/cache/nginx/tailcale-cert.pem";
  #   listen = [
  #     {
  #       inherit (config.ascii.system.cache.ssl) port;
  #       addr = "0.0.0.0";
  #       ssl = true;
  #     }
  #   ];
  # };
}
