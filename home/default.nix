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
  color = {
    red = "31";
    green = "32";
    yellow = "33";
    blue = "34";
    magenta = "35";
    cyan = "36";
    white = "97";
    light = {
      gray = "37";
      red = "91";
      green = "92";
      yellow = "93";
      blue = "94";
      magenta = "95";
      cyan = "96";
    };
  };
  font = {
    reset = "0";
    bold = "1";
    faint = "2";
    italics = "3";
    underline = "4";
  };
  format = font: color: "${font};${color}";
  escape = input: "\\e[${input}m";
in
{
  manual.manpages.enable = false;
  nixpkgs.config.allowUnfree = true;
  news.display = "silent";
  xdg.enable = true;
  services.home-manager.autoUpgrade.enable = true;
  services.home-manager.autoUpgrade.frequency = "weekly";
  programs = {
    home-manager.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "base16";
      };
    };
    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra =
        (
          if (config.home.username == "root") then
            ''
              export PS1="${escape (format font.bold color.red)}\u${escape font.reset}${escape color.white}@\h:${escape color.cyan}[\w]: ${escape font.reset}"
            ''
          else
            ''
              export PS1="${escape color.green}\u${escape color.white}@\h:${escape color.cyan}[\w]: ${escape font.reset}"
            ''
        )
        + ''
          if [ -d ${config.home.homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
            . "${config.home.homeDirectory}/.nix-profile/etc/profile.d/hm-session-vars.sh"
          fi
        '';
    };
  };
  home = {
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
