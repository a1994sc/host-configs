{
  description = "Home Manager";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    NUR.url = "github:nix-community/NUR";
    nxc.url = "git+https://gitlab.inria.fr/nixos-compose/nixos-compose.git";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # agenix = {
    #   url = "github:ryantm/agenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      user = {
        root = "root";
      };
      arch = {
        x64 = "x86_64-linux";
        arm = "aarch64-linux";
      };
      fqdn = {
        adrp = ".adrp.xyz";
      };
      mkHomeConfig =
        {
          username,
          system ? arch.x64,
          homeDirectory ? "/home/${username}",
          extraModules ? [ ],
          ...
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              inputs
              system
              username
              homeDirectory
              ;
          };
          modules = [
            ./home/root/.
            {
              nixpkgs.overlays = [
                (inputs.nxc.lib.nur {
                  inherit (inputs) NUR;
                  inherit nixpkgs system;
                }).overlay
              ];
            }
          ] ++ extraModules;
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      eachSystem =
        f: nixpkgs.lib.genAttrs systems (system: f inputs.unstablepkgs.legacyPackages.${system});

      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      nixosConfigurations = {
        puck = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./.
            ./hosts/puck
          ];
        };
      };
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    };
}
