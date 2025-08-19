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
    (
      _:
      let
        files = builtins.readDir (inputs.self.outPath + "/hosts/lenus/config");
        nixFiles = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix" name != null) (
          builtins.attrNames files
        );
        configImport = map (name: inputs.self.outPath + "/hosts/lenus/config/${name}") nixFiles;
      in
      {
        imports = [
          # keep-sorted start block=yes case=no
          (inputs.self.outPath + "/hosts/lenus/disk-configuration.nix")
          (inputs.self.outPath + "/hosts/lenus/hardware-configuration.nix")
          (inputs.self.outPath + "/users/ascii")
          (inputs.self.outPath + "/users/root")
          (inputs.self.outPath + "/users/vroze")
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
