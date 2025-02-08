{ pkgs }:
let
  pname = "vmlinuz-amd64";
  version = "1.9.3";
  sha256 = "sha256-60ipJwWEm5HM68EBS5ZjyYkOnL6cDXCI8RrFV6T/3W8=";
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
