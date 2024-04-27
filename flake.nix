{
  description = "Home Manager";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # NUR.url = "github:nix-community/NUR";
    # nxc.url = "git+https://gitlab.inria.fr/nixos-compose/nixos-compose.git";
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
    };
}
