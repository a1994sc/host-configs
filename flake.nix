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
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
      nixosConfigurations = {
        puck = builtins.import ./hosts/puck {
          inherit nixpkgs inputs;
          inherit (self) outputs;
          inherit self;
        };
        danu-01 = builtins.import ./hosts/danu-01 {
          inherit nixpkgs inputs;
          inherit (self) outputs;
          inherit self;
        };
        danu-02 = builtins.import ./hosts/danu-02 {
          inherit nixpkgs inputs;
          inherit (self) outputs;
          inherit self;
        };
        # livedisk = builtins.import ./hosts/livedisk {
        #   inherit nixpkgs inputs;
        #   inherit (self) outputs;
        #   inherit self;
        # };
      };
    }
    // flake-utils.lib.eachSystem sys (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs (inputs.self.outPath + "/treefmt.nix");
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
        ];
      in
      {
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = inputs.self.outPath;
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
        packages = inputs.ascii-pkgs.packages.${system};
      }
    );
}
