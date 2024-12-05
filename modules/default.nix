{
  version,
  pkgs,
  ...
}:
{
  # keep-sorted start block=yes
  environment.systemPackages = with pkgs; [
    git
    htop
    micro
    wget
  ];
  environment.variables = {
    # keep-sorted start
    HISTCONTROL = "ignoredups";
    HISTFILE = "$HOME/.bash_eternal_history";
    HISTFILESIZE = "";
    HISTSIZE = "";
    HISTTIMEFORMAT = "[%F %T] ";
    PROMPT_COMMAND = "history -a; history -c; history -r; $PROMPT_COMMAND";
    # keep-sorted end
  };
  networking = {
    domain = "adrp.xyz";
    search = [ "adrp.xyz" ];
    wireless.enable = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    firewall.enable = false;
  };
  nix.gc.automatic = false;
  programs.bash.completion.enable = true;
  programs.nh = {
    enable = true;
    flake = /etc/nixos;
    package = pkgs.unstable.nh;
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d";
      dates = "daily";
    };
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  services.xserver.enable = false;
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  system.stateVersion = version;
  time.timeZone = "America/New_York";
  # keep-sorted end
}
