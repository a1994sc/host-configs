{
  pkgs,
  inputs,
  system,
  ...
}:
let
  proton-cli = pkgs.stdenv.mkDerivation {
    name = "proton-mail-export-cli";
    src = pkgs.fetchurl {
      url = "https://proton.me/download/export-tool/proton-mail-export-cli-linux_x86_64.tar.gz";
      hash = "sha256-qHHdJKu0Inaop5U76CGLtC4PTesUm4RvfcKctXiE7Jg=";
    };
    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.stdenv.cc.cc ];
    installPhase = ''
      cp -R . $out/
      ln -s /tmp/ $out/logs
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # keep-sorted start block=yes case=no remove_duplicates=yes
    btrfs-assistant
    docker-compose
    duf
    git
    inputs.disko.packages.${system}.default
    inputs.nix-alien.packages.${system}.nix-alien
    solaar
    wget
    yubikey-manager
    yubikey-personalization
    yubioath-flutter
    pass
    # keep-sorted end
    (pkgs.buildFHSEnv {
      name = "proton-mail-export-cli";
      targetPkgs = _pkgs: [ proton-cli ];
      multiPkgs = _pkgs: [ ];
      runScript = "${proton-cli}/proton-mail-export-cli";
    })
  ];
  programs.nix-ld.enable = true;
}
