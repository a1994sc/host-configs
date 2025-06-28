{
  pkgs,
  inputs,
  system,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # keep-sorted start block=yes case=no remove_duplicates=yes
    btrfs-assistant
    docker-compose
    duf
    fish
    fishPlugins.grc
    fishPlugins.tide
    git
    grc
    htop
    hunspell
    inputs.agenix.packages.${system}.agenix
    inputs.agenix.packages.${system}.default
    inputs.disko.packages.${system}.default
    inputs.nix-alien.packages.${system}.nix-alien
    kdePackages.discover
    libreoffice-qt6-still
    micro
    python3
    qemu_full
    rage
    snapper
    solaar
    speedcrunch
    staging.pcsclite
    unstable.nh
    vanilla-dmz
    virtiofsd
    vlc
    wget
    yubikey-manager
    yubikey-personalization
    yubioath-flutter
    ventoy-full
    # keep-sorted end
  ];
  programs.nix-ld.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
  ];
}
