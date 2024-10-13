{
  pkgs,
  config,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      staging.pcsclite
      speedcrunch
      vanilla-dmz
      kdePackages.discover
      headsetcontrol
    ];
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      # SSH_ASKPASS_REQUIRE = "prefer";
    };
  };
  programs = {
    gnome-disks.enable = true;
    file-roller.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
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
