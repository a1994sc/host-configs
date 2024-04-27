{
  description = "Home Manager";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
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
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      user = {
        root = "root";
      };
      systems = {
        x64 = "x86_64-linux";
        arm = "aarch64-linux";
      };
      fqdn = {
        adrp = ".adrp.xyz";
      };
      mkHomeConfig =
        {
          username,
          system ? systems.x64,
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
      homeConfigurations = {
        ${user.root} = mkHomeConfig {
          username = user.root;
          homeDirectory = "/${user.root}";
        };
      };
    };
}
