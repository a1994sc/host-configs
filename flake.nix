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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
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
          modules = [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.root = import ./home/root;
            }
          ] ++ extraModules;
        };
    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations =
        let
          hm-custodian = {
            home-manager.users.custodian = import ./home/custodian;
          };
          conf = {
            dns1.extraModules = [
              hm-custodian
              ./hosts/dns1
            ];
            dns2.extraModules = [
              hm-custodian
              ./hosts/dns2
            ];
            # primary dns
            menrva.extraModules = [
              hm-custodian
              inputs.disko.nixosModules.disko
              ./hosts/menrva
            ];
            # primary dns
            athena.extraModules = [
              hm-custodian
              ./hosts/athena
            ];
            # personal laptop
            puck.extraModules = [
              ./.
              inputs.nixos-hardware.nixosModules.framework-13-7040-amd
              ./hosts/puck
            ];
          };
        in
        {
          puck = mkHost { inherit (conf.puck) extraModules; };
          menrva = mkHost { inherit (conf.menrva) extraModules; };
          athena = mkHost { inherit (conf.athena) extraModules; };
          dns2 = mkHost { inherit (conf.dns2) extraModules; };
        };
    }
    // flake-utils.lib.eachDefaultSystem (
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
          pkgs.nix-prefetch
          pkgs.git
          pkgs.gnumake
          pkgs.nh
          pkgs.nix-tree
        ];
      in
      {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt.enable = true;
              nixfmt.package = pkgs.nixfmt-rfc-style;
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
