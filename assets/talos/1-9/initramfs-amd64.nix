{ pkgs }:
let
  name = "initramfs-amd64";
  version = "v1.9.1";
  sha256 = "sha256-dbaNUEfg4lUxKr1dmzAERmM0fQ8yBfO9pNAGNjxQrzI=";
in
pkgs.stdenv.mkDerivation {
  inherit name version;
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://github.com/siderolabs/talos/releases/download/${version}/${name}.xz";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp $src $out/${name}.xz
  '';
}
