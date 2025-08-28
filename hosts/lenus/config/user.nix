{
  pkgs,
  ...
}:
{
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  programs.fish.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  users.users.ascii.shell = pkgs.fish;
  users.users.ascii.packages = with pkgs; [
    # keep-sorted start
    firefox
    gnupg
    # keep-sorted end
  ];
  services.logind.extraConfig = "RuntimeDirectorySize=50%";
}
