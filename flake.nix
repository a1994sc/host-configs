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
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    NUR.url = "github:nix-community/NUR";
    nxc = {
      url = "git+https://gitlab.inria.fr/nixos-compose/nixos-compose.git";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.kapack.follows = "kapack";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
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
      inherit (self) outputs;
      mkApp =
        { program }:
        {
          inherit program;
          type = "app";
        };
      mkHost =
        {
          system ? "x86_64-linux",
          version ? "23.11",
          extraModules ? [ ],
        }:
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
          modules = [ ./. ] ++ extraModules;
        };
    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        box = mkHost { extraModules = [ ./hosts/box ]; };
        dns1 = mkHost { extraModules = [ ./hosts/dns1 ]; };
        dns2 = mkHost { extraModules = [ ./hosts/dns2 ]; };
        puck = mkHost {
          extraModules = [
            inputs.nixos-hardware.nixosModules.intel-nuc-8i7beh
            ./hosts/puck
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
        agepkgs = inputs.agenix.packages.${system}.agenix;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        formatter = treefmtEval.config.build.wrapper;
        apps = {
          default = mkApp { program = "${pkgs.nh}/bin/nh"; };
          # keep-sorted start block=yes case=no
          agenix = mkApp { program = "${agepkgs}/bin/agenix"; };
          git = mkApp { program = "${pkgs.gitMinimal}/bin/git"; };
          nh = mkApp { program = "${pkgs.nh}/bin/nh"; };
          nix = mkApp { program = "${pkgs.nix}/bin/nix"; };
          nix-env = mkApp { program = "${pkgs.nix}/bin/nix-env"; };
          nix-store = mkApp { program = "${pkgs.nix}/bin/nix-store"; };
          # keep-sorted end
        };
      }
    );
}
