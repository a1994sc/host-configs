{
  config,
  pkgs,
  lib,
  inputs,
  username,
  homeDirectory,
  ...
}:
let
  stable = with pkgs; [
    age-plugin-yubikey
    rage
    sops
    yq-go
    htop
    bat
    git
  ];
in
{
  manual.manpages.enable = false;
  nixpkgs.config.allowUnfree = true;
  news.display = "silent";
  xdg.enable = true;
  services.home-manager.autoUpgrade.enable = true;
  services.home-manager.autoUpgrade.frequency = "weekly";
  programs.home-manager.enable = true;
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };
  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "23.11";
    sessionVariables =
      let
        home = config.home.homeDirectory;
      in
      {
        HISTFILESIZE = "";
        HISTSIZE = "";
        HISTTIMEFORMAT = "[%F %T] ";
        HISTCONTROL = "ignoredups";
        HISTFILE = "${home}/.bash_eternal_history";
      };
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      ll = "${pkgs.eza}/bin/eza -lah";
      cat = "${pkgs.bat}/bin/bat";
    };
    packages = stable;
  };
}
