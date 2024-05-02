{
  config,
  pkgs,
  username,
  homeDirectory,
  ...
}:
let
  stable = with pkgs; [
    # keep-sorted start
    age-plugin-yubikey
    bat
    git
    htop
    rage
    sops
    yq-go
    # keep-sorted end
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
    inherit username;
    inherit homeDirectory;
    stateVersion = "23.11";
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
