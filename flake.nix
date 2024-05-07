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
      inputs.systems.follows = "systems";
      url = "github:numtide/flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    NUR.url = "github:nix-community/NUR";
    nxc = {
      url = "git+https://gitlab.inria.fr/nixos-compose/nixos-compose.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
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
    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        puck =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit inputs outputs system;
            };
            modules = [
              ./.
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
