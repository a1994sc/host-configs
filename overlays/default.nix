{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: import ../pkgs {pkgs = final;};

  # When applied, the staging nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.staging' and `pkgs.unstable`
  packages =
    final: _prev:
    let
      confg = {
        inherit (final) system;
        config.allowUnfree = true;
      };
    in
    {
      staging = import inputs.nixpkgs-staging confg;
      unstable = import inputs.nixpkgs-unstable confg;
    };

  build-packages =
    _final: prev:
    let
      inherit (prev) lib pkgs;
      scope = lib.makeScope pkgs.newScope (_self: {
        inherit inputs;
      });
    in
    {
      build = lib.filesystem.packagesFromDirectoryRecursive {
        inherit (scope) callPackage;
        directory = ../pkgs;
      };
    };
}
