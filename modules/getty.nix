{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.ascii.system.getty;
in
{
  options.ascii.system.getty = {
    enable = lib.mkEnableOption "getty";
    user = lib.mkOption {
      type = lib.types.str;
      default = "getty-cat";
    };
  };

  config = lib.mkIf cfg.enable {
    services.getty = {
      autologinUser = cfg.user;
      loginProgram = "${pkgs.tmux}/bin/tmux";
      loginOptions = "new-session '${pkgs.htop}/bin/htop'";
    };
    users.users.${cfg.user} = {
      group = cfg.user;
      isSystemUser = true;
    };
    users.groups.${cfg.user} = { };
  };
}
