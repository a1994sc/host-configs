{
  system,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
in
{
  # keep-sorted start block=yes case=no
  nix.gc.automatic = true;
  nix.gc.dates = "Tue 02:00";
  nix.gc.options = "--delete-older-than 30d";
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "daily" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.bash-prompt-prefix = "\\[\\e[31;11m\\][develop]\\[\\e[0;11m\\]-";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.max-jobs = 8;
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
    "danu-01.barb-neon.ts.net:wjXASA3VF+ryB3brRo8vPMuYwVGrjsIa+a3pe8zV86o="
    "danu-02.barb-neon.ts.net:SqCBNF/wWsRQU5QGLhoV58KEcEZKRW39LQxxXYWLH/0="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nixpkgs.config.allowUnfree = true;
  # keep-sorted end
  nix.extraOptions = ''
    min-free = ${toString (1024 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024 * 4)}
  '';
  nix.settings.substituters =
    [
      "https://danu-01.barb-neon.ts.net?priority=6"
      "https://danu-02.barb-neon.ts.net?priority=7"
      "https://${danu-01.domain}?priority=10"
      "https://${danu-02.domain}?priority=15"
    ]
    ++ (builtins.map (alt: "https://${alt}.${danu-01.domain}?priority=10") (
      builtins.attrNames danu-01.alts
    ))
    ++ (builtins.map (alt: "https://${alt}.${danu-02.domain}?priority=15") (
      builtins.attrNames danu-02.alts
    ));
  nixpkgs.overlays = [
    outputs.overlays.packages
    (
      _final: _prev:
      builtins.listToAttrs (
        builtins.map (name: {
          inherit name;
          value = outputs.packages.${system}.${name};
        }) (builtins.attrNames outputs.packages.${system})
      )
    )
  ];
}
