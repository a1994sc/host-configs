{
  pkgs,
  ...
}:
{
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  services.pcscd.enable = true;
  users.users.ascii.packages = with pkgs; [
    # keep-sorted start
    firefox
    gnupg
    podman
    # keep-sorted end
  ];
  users.users.vroze.packages = with pkgs; [
    # keep-sorted start
    firefox
    google-chrome
    # keep-sorted end
  ];
  services.logind.extraConfig = "RuntimeDirectorySize=50%";
}
