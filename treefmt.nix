{ pkgs, ... }:
{
  # keep-sorted start block=yes newline_separated=yes prefix_order=projectRootFile,
  projectRootFile = "flake.nix";

  programs.deadnix.enable = true;

  programs.dprint = {
    enable = true;
    settings = {
      includes = [
        "**/*.json"
        "**/*.md"
        "**/*.toml"
      ];
      excludes = [ "flake.lock" ];
      plugins =
        let
          dprintWasmPluginUrl = n: v: "https://plugins.dprint.dev/${n}-${v}.wasm";
        in
        [
          (dprintWasmPluginUrl "json" "0.19.0")
          (dprintWasmPluginUrl "markdown" "0.17.0")
          (dprintWasmPluginUrl "toml" "0.6.2")
        ];
    };
  };

  programs.keep-sorted.enable = true;

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };

  programs.statix.enable = true;

  programs.yamlfmt.enable = true;

  settings.global.excludes = [ "secrets/**" ];
  # keep-sorted end
}
