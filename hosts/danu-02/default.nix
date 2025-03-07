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
    ./disk-configuration.nix
    {
      imports = [
        ./agenix.nix
        ./configuration.nix
        ./hardware-configuration.nix
        ../../users/custodian
      ];
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGZ4rS2mbNzQYWtYxZIpDv+xLkI4UHLov8ICjH3FkkG";
    }
  ];
}
