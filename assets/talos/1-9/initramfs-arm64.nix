{ pkgs }:
let
  pname = "initramfs-arm64";
  version = "1.9.3";
  sha256 = "sha256-kCaqCOARUvgMknF40prGYYpcvfYmFYUkwKuyVN3f+g8=";
in
pkgs.stdenv.mkDerivation {
  inherit version pname;
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://github.com/siderolabs/talos/releases/download/v${version}/${pname}.xz";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.xz
  '';
}
