{
  inputs,
  system,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages.${system}.default
    pkgs.duf
    pkgs.rage
  ];

  system.autoUpgrade.dates = "Tue 04:00";
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
}
