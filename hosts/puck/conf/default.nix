{
  pkgs,
  inputs,
  system,
  ...
}:
let
  # Read all files in the current directory
  files = builtins.readDir ./.;

  # Filter out default.nix and non-.nix files
  nixFiles = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix" name != null) (
    builtins.attrNames files
  );

  # Create a list of import statements
  imports = map (name: ./. + "/${name}") nixFiles;
in
{
  inherit imports;
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
      solaar
      docker-compose

      libreoffice-qt6-still
      hunspell
      vlc
      inputs.nix-alien.packages.${system}.nix-alien
      qemu_full
    ];
  };
  programs.nix-ld.enable = true;
}
