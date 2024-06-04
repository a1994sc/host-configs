{ config, pkgs, ... }:
let
  stable =
    let
      ehistfilter = ''cat ${config.home.sessionVariables.HISTFILE} | grep -v -e "^#[0-9]*" | grep -v -e "^ehistory"'';
    in
    with pkgs;
    [
      # keep-sorted start
      yq-go
      # keep-sorted end
      (writeShellScriptBin "ehistory" ''
        ${ehistfilter} | grep --color "$@"
      '')
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
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PS1="\e[1;31m\u\e[97m@\h\e[0m:\e[36m[\w]: \e[0m"
      if [ -d ${config.home.homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . "${config.home.homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };
  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "24.05";
    sessionVariables =
      let
        home = config.home.homeDirectory;
      in
      {
        # keep-sorted start
        HISTCONTROL = "ignoredups";
        HISTFILE = "${home}/.bash_eternal_history";
        HISTFILESIZE = "";
        HISTSIZE = "";
        HISTTIMEFORMAT = "[%F %T] ";
        # keep-sorted end
      };
    shellAliases = {
      # keep-sorted start
      cat = "${pkgs.bat}/bin/bat";
      ll = "${pkgs.eza}/bin/eza -lah";
      ls = "${pkgs.eza}/bin/eza";
      # keep-sorted end
    };
    packages = stable;
  };
}
