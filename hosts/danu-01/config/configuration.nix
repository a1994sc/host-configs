{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  # keep-sorted start block=yes case=no
  ascii.system.dns.enable = true;
  boot.enableContainers = false;
  boot.initrd.systemd.enable = true; # required by system.etc.overlay
  environment.systemPackages = [
    pkgs.doggo
    pkgs.git
  ];
  nix.channel.enable = false;
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
  # keeps a 200MB copy of nixpkgs out of /etc; the flake is the only entry point here
  nixpkgs.flake.setFlakeRegistry = false;
  nixpkgs.flake.setNixPath = false;
  services.userborn.enable = true; # replaces the perl user/group activation script
  system.disableInstallerTools = true;
  system.etc.overlay.enable = true; # /etc as an overlay instead of perl setup-etc.pl
  system.tools.nixos-generate-config.enable = false;
  systemd.oomd.enable = false;
  time.timeZone = "America/New_York";
  # keep-sorted end
}
