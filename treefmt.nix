{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };
  programs.jsonfmt = {
    enable = true;
    package = pkgs.jsonfmt;
  };
}
