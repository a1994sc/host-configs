{
  inputs,
  lib,
  self,
  ...
}:
with lib;
let
  nixFiles =
    dir:
    listToAttrs (
      map (file: nameValuePair (removeSuffix ".nix" (baseNameOf file)) file) (
        attrNames (
          filterAttrs (name: type: (type == "regular") && (hasSuffix ".nix" name)) (builtins.readDir dir)
        )
      )
    );
  dirs = dir: attrNames (filterAttrs (_name: type: type == "directory") (builtins.readDir dir));
  nixFilesNoDefault = dir: filterAttrs (name: _: name != "default") (nixFiles dir);
  nixFilesNoDefault' = dir: attrValues (nixFilesNoDefault dir);
  defaultImport = dir: map (name: "${dir}/${name}") ((nixFilesNoDefault' dir) ++ (dirs dir));
in
{
  imports = defaultImport (inputs.self.outPath + "/modules");
}
