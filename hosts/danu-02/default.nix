{
  nixpkgs,
  inputs,
  outputs,
  self,
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
      self
      ;
  };
  modules = [
    ../../.
    inputs.disko.nixosModules.disko
    ./disk-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.comin.nixosModules.comin
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    {
      imports = [
        ./configuration.nix
        ./hardware-configuration.nix
        ../../users/custodian
      ];
    }
  ];
}
