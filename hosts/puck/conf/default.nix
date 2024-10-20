{
  pkgs,
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
    ];
  };
}
