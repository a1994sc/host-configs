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
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.pre-commit-hooks.follows = "pre-commit-hooks";
      # inputs.treefmt-nix.follows = "treefmt-nix";
    };
    ascii-pkgs.url = "github:a1994sc/nix-pkgs";
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
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:cachix/pre-commit-hooks.nix";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  nixConfig = {
    extra-trusted-substituters = [
      "https://a1994sc.cachix.org"
    ];
    extra-trusted-public-keys = [
      "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
    ];
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
      agenix-rekey = inputs.agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = {
          inherit (self.nixosConfigurations) danu-01 danu-02 puck;
        };
      };
    }
    // flake-utils.lib.eachSystem sys (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.agenix-rekey.overlays.default ];
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        shellHook =
          self.checks.${system}.pre-commit-check.shellHook
          + ''
            export TMPDIR="/run/user/$UID/age"
            mkdir -p $TMPDIR
          '';
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [
          pkgs.git
          pkgs.gnumake
          pkgs.nh
          pkgs.mdbook
          pkgs.agenix-rekey
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
        packages =
          nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            directory = ./pkgs;
          }
          // inputs.ascii-pkgs.packages.${system}
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
