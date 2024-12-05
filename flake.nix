{
  description = "Home Manager";

  inputs = {
    # keep-sorted start block=yes case=no
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kapack = {
      url = "github:oar-team/nur-kapack";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    NUR.url = "github:nix-community/NUR";
    nxc = {
      url = "git+https://gitlab.inria.fr/nixos-compose/nixos-compose.git";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.kapack.follows = "kapack";
    };
    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      url = "github:cachix/pre-commit-hooks.nix";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    inputs@{
      # keep-sorted start
      flake-utils,
      nixpkgs,
      self,
      treefmt-nix,
      # keep-sorted end
      ...
    }:
    let
      sys = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = builtins.listToAttrs (
        map (name: {
          inherit name;
          value = builtins.import ./hosts/${name} {
            inherit nixpkgs inputs;
            inherit (self) outputs;
          };
        }) (builtins.attrNames (builtins.readDir ./hosts))
      );
    }
    // flake-utils.lib.eachSystem sys (
      system:
      let
        pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
        agepkgs = inputs.agenix.packages.${system}.agenix;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        shellHook =
          self.checks.${system}.pre-commit-check.shellHook
          + ''
            export TMPDIR="/run/user/$UID/age"
            mkdir -p $TMPDIR
          '';
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [
          agepkgs
          pkgs.git
          pkgs.gnumake
          pkgs.nh
          pkgs.mdbook
          pkgs.d2
        ];
      in
      {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              checkmake.enable = true;
              check-executables-have-shebangs.enable = true;
              check-shebang-scripts-are-executable.enable = true;
            };
          };
        };
        formatter = treefmtEval.config.build.wrapper;
        devShells.default = nixpkgs.legacyPackages.${system}.mkShell { inherit shellHook buildInputs; };
      }
    );
}
