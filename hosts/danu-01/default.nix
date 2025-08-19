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
    (
      _:
      let
        files = builtins.readDir (inputs.self.outPath + "/hosts/danu-01/config");
        nixFiles = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix" name != null) (
          builtins.attrNames files
        );
        configImport = map (name: inputs.self.outPath + "/hosts/danu-01/config/${name}") nixFiles;
      in
      {
        imports = [
          # keep-sorted start block=yes case=no
          (inputs.self.outPath + "/hosts/danu-01/disk-configuration.nix")
          (inputs.self.outPath + "/modules")
          (inputs.self.outPath + "/settings/certs")
          (inputs.self.outPath + "/users/custodian")
          (inputs.self.outPath + "/users/root")
          inputs.agenix.nixosModules.default
          inputs.comin.nixosModules.comin
          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          # keep-sorted end
        ]
        ++ configImport;
        system.stateVersion = version;
      }
    )
  ];
}
