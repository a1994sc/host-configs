{
  nixpkgs,
  inputs,
  outputs,
  ...
}:
let
  system = "x86_64-linux";
  version = "23.11";
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
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.comin.nixosModules.comin
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    {
      imports = [
        ../../users/ascii
        ../../users/vroze
        ./conf
        ./disk-configuration.nix
        ./hardware-configuration.nix
      ];
    }
  ];
}
