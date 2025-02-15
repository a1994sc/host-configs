{ lib, config, ... }:
let
  cfg = config.ascii.system.bare;
in
{
  options.ascii.system.bare = {
    enable = lib.mkEnableOption "nix";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
