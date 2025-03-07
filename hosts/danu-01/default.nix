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
        ./agenix.nix
        ./configuration.nix
        ./hardware-configuration.nix
        ../../users/custodian
      ];
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgtCFdGSN+0iuaD6WpspN7tB7bZk0nuUqeY4Mq7k5Df";
    }
  ];
}
