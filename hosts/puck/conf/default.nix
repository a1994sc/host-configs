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
    "https:10.3.10.5:443?priority=10"
    "https:10.3.10.6:443?priority=10"
  ];
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
  ];
}
