{
  nixpkgs,
  inputs,
  outputs,
  ...
}:
let
  system = "x86_64-linux";
  version = "24.11";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit
      inputs
      outputs
      system
      version
      ;
  };
  modules = [
    ../../.
    "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
    "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
    inputs.disko.nixosModules.disko
    inputs.comin.nixosModules.comin
    inputs.home-manager.nixosModules.home-manager
    {
      imports = [
        ./hardware-configuration.nix
      ];
    }
    {
      system.stateVersion = version;
    }
  ];
}
