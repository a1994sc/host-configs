{
  system,
  outputs,
  ...
}:
{
  # keep-sorted start block=yes case=no
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "daily" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.bash-prompt-prefix = "\\[\\e[31;11m\\][develop]\\[\\e[0;11m\\]-";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.max-jobs = "auto";
  nix.settings.trusted-public-keys = [
    "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
    "danu-01.barb-neon.ts.net:wjXASA3VF+ryB3brRo8vPMuYwVGrjsIa+a3pe8zV86o="
    "danu-02.barb-neon.ts.net:SqCBNF/wWsRQU5QGLhoV58KEcEZKRW39LQxxXYWLH/0="
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
