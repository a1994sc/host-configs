{
  pkgs,
  lib,
  ...
}:
{
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    pcmciaUtils
    pcsc-tools
    opensc
  ];
}
