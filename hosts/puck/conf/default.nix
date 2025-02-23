{
  pkgs,
  inputs,
  system,
  ...
}:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./container.nix
    ./network.nix
    ./steam.nix
    ./user.nix
    ./window.nix
  ];
  environment = {
    systemPackages = with pkgs; [
      staging.pcsclite
      speedcrunch
      vanilla-dmz
      kdePackages.discover
      snapper
      yubikey-personalization
      yubikey-manager
      yubioath-flutter
      btrfs-assistant

      libreoffice-qt6-still
      hunspell
      vlc
      inputs.nix-alien.packages.${system}.nix-alien
    ];
  };
  programs.nix-ld.enable = true;
  nix.settings.substituters = [
    "https://danu-01.adrp.xyz?priority=10"
    "https://danu-02.adrp.xyz?priority=10"
    "https://ascii.danu-01.adrp.xyz?priority=15"
    "https://ascii.danu-02.adrp.xyz?priority=10"
    "https://terra.danu-01.adrp.xyz?priority=10"
    "https://terra.danu-02.adrp.xyz?priority=15"
  ];
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
  ];
}
