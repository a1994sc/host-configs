{
  inputs,
  system,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
    pkgs.duf
    pkgs.rage
    (lib.hiPrio pkgs.uutils-coreutils-noprefix)
    pkgs.doggo
  ];

  system.autoUpgrade.dates = "Thu 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
}
