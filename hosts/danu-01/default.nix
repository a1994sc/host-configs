{
  nixpkgs,
  inputs,
  outputs,
  self,
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
      self
      ;
  };
  modules = [
    ../../.
    ./disk-configuration.nix
    {
      imports = [
        ./configuration.nix
        ./hardware-configuration.nix
        ../../users/custodian
      ];
    }
  ];
}
