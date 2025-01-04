{ pkgs }:
let
  name = "vmlinuz-amd64";
  version = "v1.9.1";
  sha256 = "sha256-AIRxI81EyG2YHD05mTwet/40PS1Zt9sTn9KRbQhaCzs=";
in
pkgs.stdenv.mkDerivation {
  inherit name version;
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://github.com/siderolabs/talos/releases/download/${version}/${name}";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp $src $out/${name}
  '';
}
