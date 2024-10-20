{
  pkgs,
  config,
  lib,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkgs:
    builtins.elem (pkgs.lib.getName pkgs) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraLibraries = pkgs: [
        pkgs.openssl
        pkgs.nghttp2
        pkgs.libidn2
        pkgs.rtmpdump
        pkgs.libpsl
        pkgs.curl
        pkgs.krb5
        pkgs.keyutils
      ];
    };
  };
}
