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
    (
      _:
      let
        files = builtins.readDir ./config;
        nixFiles = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix" name != null) (
          builtins.attrNames files
        );
        configImport = map (name: ./config + "/${name}") nixFiles;
      in
      {
        imports = [
          ../../users/custodian
        ] ++ configImport;
      }
    )
  ];
}
