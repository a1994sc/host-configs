{ pkgs }:
let
  pname = "vmlinuz-amd64";
  version = "1.9.1";
  sha256 = "sha256-AIRxI81EyG2YHD05mTwet/40PS1Zt9sTn9KRbQhaCzs=";
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
    cp $src $out/${pname}.xz
  '';
}
