{
  nixpkgs,
  inputs,
  outputs,
  self,
  ...
}:
let
  system = "x86_64-linux";
  version = "26.05";
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
        files = builtins.readDir (inputs.self.outPath + "/hosts/danu-02/config");
        nixFiles = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix" name != null) (
          builtins.attrNames files
        );
        configImport = map (name: inputs.self.outPath + "/hosts/danu-02/config/${name}") nixFiles;
      in
      {
        imports = [
          # keep-sorted start block=yes case=no
          (inputs.self.outPath + "/hosts/danu-02/disk-configuration.nix")
          (inputs.self.outPath + "/modules/dns.nix")
          (inputs.self.outPath + "/users/custodian/minimal.nix")
          inputs.comin.nixosModules.comin
          inputs.disko.nixosModules.disko
          # keep-sorted end
        ]
        ++ configImport;
        system.stateVersion = version;
      }
    )
  ];
}
