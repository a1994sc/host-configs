{ pkgs }:
let
  pname = "initramfs-amd64";
  version = "1.9.3";
  sha256 = "sha256-WlEV27yTwXUnIEhjNsZ4QqCwXmhJhgn7EIO+maLu7+k=";
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
