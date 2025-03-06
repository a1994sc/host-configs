{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.ascii.security.harden;
in
{
  options.ascii.security.harden = {
    enable = lib.mkEnableOption "certs";
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "login.defs".text = pkgs.lib.mkForce ''
        ENCRYPT_METHOD SHA512
      '';
      "login.defs".source = lib.mkForce (
        pkgs.writeText "login.defs" ''
          DEFAULT_HOME yes

          SYS_UID_MIN 400
          SYS_UID_MAX 999
          UID_MIN 1000
          UID_MAX 29999

          SYS_GID_MIN 400
          SYS_GID_MAX 999
          GID_MIN 1000
          GID_MAX 29999

          TTYGROUP tty
          TTYPERM 0620

          # Ensure privacy for newly created home directories.
          UMASK 077

          # Uncomment this and install chfn SUID to allow nonroot
          # users to change their account GECOS information.
          # This should be made configurable.
          #CHFN_RESTRICT frwh
        ''
      );
    };
    services.openssh.settings.Ciphers = [
      "aes256-ctr"
      "aes192-ctr"
      "aes128-ctr"
    ];
    # services.openssh.extraConfig = ''
    #   ClientAliveInterval 600
    # '';
    security.apparmor.enable = true;
  };
}
