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
    {
      imports = [
        ./configuration.nix
        ./disk-configuration.nix
        ./hardware-configuration.nix
      ];
      home-manager.users.custodian = import ../../home/custodian;
    }
  ];
}