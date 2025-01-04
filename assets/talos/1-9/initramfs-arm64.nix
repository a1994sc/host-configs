{ pkgs }:
let
  pname = "initramfs-arm64";
  version = "1.9.1";
  sha256 = "sha256-8X/GJBFaWBaDIZeQ58+NIpHH9uB2Jl2mcZaWKgc+zio=";
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
