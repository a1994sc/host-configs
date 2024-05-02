{ pkgs, ... }:
{
  # keep-sorted start block=yes newline_separated=yes prefix_order=projectRootFile,
  projectRootFile = "flake.nix";

  programs.deadnix.enable = true;

  programs.keep-sorted.enable = true;

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };

  programs.statix.enable = true;

  settings.global.excludes = [ "./.vscode/tasks.json" ];
  # keep-sorted end
}
