{
  system,
  pkgs,
  ...
}:
{
  # keep-sorted start block=yes case=no
  environment.variables.DIRENV_WARN_TIMEOUT = "100h";
  environment.variables.HISTCONTROL = "ignoredups";
  environment.variables.HISTFILE = "$HOME/.bash_eternal_history";
  environment.variables.HISTFILESIZE = "";
  environment.variables.HISTSIZE = "";
  environment.variables.HISTTIMEFORMAT = "[%F %T] ";
  environment.variables.PROMPT_COMMAND = "history -a; history -c; history -r; $PROMPT_COMMAND";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  programs.fish.vendor.completions.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.dates = "02:00";
  system.autoUpgrade.enable = true;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.fish;
  # keep-sorted end
}
