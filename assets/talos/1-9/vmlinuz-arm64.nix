{ pkgs }:
let
  pname = "vmlinuz-arm64";
  version = "1.9.3";
  sha256 = "sha256-68UwTUg/GjuvGMugMOYgKW7Q0mpsKT08iAJYCMNFElo=";
in
pkgs.stdenv.mkDerivation {
  inherit version pname;
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://github.com/siderolabs/talos/releases/download/v${version}/${pname}";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}
  '';
}
