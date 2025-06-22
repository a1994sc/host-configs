{
  inputs,
  system,
  pkgs,
  self,
  ...
}:
{
  # keep-sorted start block=yes case=no
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  environment.systemPackages = [
    # keep-sorted start block=yes
    inputs.agenix.packages.${system}.agenix
    inputs.agenix.packages.${system}.default
    inputs.disko.packages.${system}.default
    pkgs.duf
    pkgs.git
    pkgs.htop
    pkgs.micro
    pkgs.python3
    pkgs.rage
    pkgs.unstable.nh
    pkgs.wget
    # keep-sorted end
  ];
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
  system.autoUpgrade.dates = "Tue 04:00";
  system.autoUpgrade.enable = true;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.fish;
  # keep-sorted end
}
