{
  pkgs,
  config,
  ...
}:
{
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # keep-sorted start
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
      # keep-sorted end
    };
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  users = {
    groups = {
      ascii = {
        gid = config.users.users.ascii.uid;
        name = "ascii";
      };
      vroze = {
        gid = config.users.users.vroze.uid;
        name = "vroze";
      };
    };
    users = {
      ascii.packages = with pkgs; [
        # keep-sorted start
        firefox
        gnupg
        google-chrome
        podman
        # keep-sorted end
      ];
      vroze = {
        # keep-sorted start block=yes case=no
        description = "Victoria Roze";
        extraGroups = [ ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ ];
        packages = with pkgs; [
          google-chrome
          firefox
        ];
        uid = 1001;
        # keep-sorted end
      };
    };
  };
}
