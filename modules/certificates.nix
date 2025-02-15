{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.ascii.security.certs;
  certs = pkgs.writeShellScriptBin "mv-certs" ''
    ${pkgs.coreutils-full}/bin/cp ${config.users.users.${cfg.user}.home}/fullchain.pem \
      ${config.users.users.${cfg.user}.home}/cert.pem \
      ${config.users.users.${cfg.user}.home}/key.pem \
      ${cfg.nginxDir}

    ${pkgs.coreutils-full}/bin/chown ${config.services.nginx.user}:${config.services.nginx.group} -R ${cfg.nginxDir}
  '';
in
{
  options.ascii.security.certs = {
    enable = lib.mkEnableOption "certs";
    user = lib.mkOption {
      type = lib.types.str;
      default = "acme";
    };
    name = lib.mkOption {
      type = lib.types.str;
    };
    sans = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    port = lib.mkOption {
      type = lib.types.ints.u16;
      default = 16917;
    };
    ca = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/certs/derpy.crt";
    };
    server = lib.mkOption {
      type = lib.types.str;
      default = "https://10.3.10.5:1443";
    };
    nginxDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/nginx/";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.stringLength cfg.name > 0;
        message = "Must provide a domain name";
      }
    ];

    users.groups.${cfg.user} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      home = "/etc/acme-sh";
      createHome = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts =
        {
          "acme-${cfg.name}" = {
            serverName = cfg.name;
            listen = [
              {
                port = 80;
                addr = "0.0.0.0";
                ssl = false;
              }
            ];
            locations."/".proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}/";
          };
        }
        // builtins.listToAttrs (
          builtins.map (san: {
            name = "acme-${san}";
            value = {
              serverName = san;
              listen = [
                {
                  port = 80;
                  addr = "0.0.0.0";
                  ssl = false;
                }
              ];
              locations."/".proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}/";
            };
          }) cfg.sans
        );
    };

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        groups = [ cfg.user ];
        commands = [
          {
            command = "${certs}/bin/mv-certs";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];

    systemd.services.acme-sh =
      let
        acme = pkgs.writeShellScriptBin "acme-certs.sh" ''
          ${pkgs.acme-sh}/bin/acme.sh --issue --standalone -d ${cfg.name} ${
            pkgs.lib.concatStringsSep " " (builtins.map (san: "-d ${san}") cfg.sans)
          } --server ${cfg.server}/acme/acme/directory --ca-bundle ${cfg.ca} \
            --fullchain-file ${config.users.users.${cfg.user}.home}/fullchain.pem \
            --cert-file ${config.users.users.${cfg.user}.home}/cert.pem \
            --key-file ${config.users.users.${cfg.user}.home}/key.pem \
            --httpport ${builtins.toString cfg.port} --force

          /run/wrappers/bin/sudo ${certs}/bin/mv-certs
        '';
      in
      {
        serviceConfig = {
          Type = "oneshot";
          User = "${config.users.users.acme.name}";
        };
        script = "${acme}/bin/acme-certs.sh";
      };

    systemd.timers.acme-sh = {
      enable = true;
      wantedBy = [ "timers.target" ];
      partOf = [ "acme-sh.service" ];
      timerConfig = {
        OnCalendar = "*-*-1,11,21 00:00:00";
        Unit = "acme-sh.service";
      };
    };
  };
}
