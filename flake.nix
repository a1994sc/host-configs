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
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
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
            inherit self;
          };
        }) (builtins.attrNames (builtins.readDir ./hosts))
      );
    }
    // flake-utils.lib.eachSystem sys (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.nix-topology.overlays.default ];
        };
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
        topology = import inputs.nix-topology {
          inherit pkgs;
          modules = [
            ./topology.nix
            # { nixosConfigurations = self.nixosConfigurations; }
            {
              nixosConfigurations = {
                inherit (self.nixosConfigurations) dns1;
                inherit (self.nixosConfigurations) dns2;
                # danu-02 = self.nixosConfigurations.danu-02;
              };
            }
          ];
        };
        packages =
          nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            directory = ./pkgs;
          }
          // builtins.listToAttrs (
            builtins.concatLists (
              builtins.concatLists (
                builtins.map
                  (
                    name:
                    builtins.map (
                      version:
                      builtins.map (asset: {
                        name = pkgs.lib.removeSuffix ".nix" "${name}-${version}-${asset}";
                        value = pkgs.callPackage ./assets/${name}/${version}/${asset} { };
                      }) (builtins.attrNames (builtins.readDir ./assets/${name}/${version}))
                    ) (builtins.attrNames (builtins.readDir ./assets/${name}))
                  )
                  (
                    builtins.attrNames (
                      pkgs.lib.attrsets.filterAttrs (_n: v: v == "directory") (builtins.readDir ./assets)
                    )
                  )
              )
            )
          );
      }
    );
}
