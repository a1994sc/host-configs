{ pkgs }:
let
  name = "vmlinuz-arm64";
  version = "v1.9.1";
  sha256 = "sha256-D46ZH4LeIJyTjrZ8zdV5R6u3LwYV22pUog+SD/H5Zeo=";
in
pkgs.stdenv.mkDerivation {
  inherit name;
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
