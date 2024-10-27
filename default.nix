{
  config,
  pkgs,
  outputs,
  version,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.age
    settings/certs
  ];

  nixpkgs.overlays = [
    outputs.overlays.packages
    outputs.overlays.build-packages
  ];
  system.stateVersion = version;
  programs.bash.enableCompletion = true;
  environment.variables = {
    # keep-sorted start
    DIRENV_WARN_TIMEOUT = "100h";
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
  };
  nix = {
    # keep-sorted start block=yes case=no
    gc = {
      automatic = false;
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };
    settings = {
      max-jobs = "auto";
      auto-optimise-store = true;
      bash-prompt-prefix = "\\[\\e[31;11m\\][develop]\\[\\e[0;11m\\]-";
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # keep-sorted end
    extraOptions = ''
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024 * 4)}
    '';
  };
  # Set your time zone.
  time.timeZone = "America/New_York";
  nixpkgs.config.allowUnfree = true;
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
  environment.systemPackages = with pkgs; [
    # keep-sorted start prefix_order=staging,unstable,
    unstable.nh
    git
    htop
    inputs.agenix.packages.${system}.agenix
    inputs.disko.packages.${system}.default
    micro
    python3
    wget
    # keep-sorted end
  ];
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      LoginGraceTime = 0;
    };
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.root = import ./users/root;
  services.comin = {
    hostname = config.networking.hostName;
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/a1994sc/host-configs.git";
        branches.main.name = "main";
      }
    ];
  };
}
