{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: import ../pkgs {pkgs = final;};

  # When applied, the staging nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.staging'
  staging-packages = final: _prev: {
    staging = import inputs.nixpkgs-staging {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
