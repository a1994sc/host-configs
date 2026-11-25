{ pkgs, ... }:
{
  # keep-sorted start block=yes case=no
  ascii.system.dns.enable = true;
  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.systemPackages = [
    pkgs.doggo
    pkgs.git
  ];
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  nix.optimise.automatic = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  time.timeZone = "America/New_York";
  # keep-sorted end
}
