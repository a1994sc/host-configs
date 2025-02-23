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
}
