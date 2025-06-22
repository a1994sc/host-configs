{
  config,
  pkgs,
  outputs,
  version,
  inputs,
  system,
  self,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.comin.nixosModules.comin
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    settings/certs
    (inputs.self.outPath + "/users/root")
  ];

  nixpkgs.overlays = [
    outputs.overlays.packages
    (
      _final: _prev:
      builtins.listToAttrs (
        builtins.map (name: {
          inherit name;
          value = outputs.packages.${system}.${name};
        }) (builtins.attrNames outputs.packages.${system})
      )
    )
  ];
  system.stateVersion = version;
  programs.bash.completion.enable = true;
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
  users.defaultUserShell = pkgs.fish;
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
  # i18n = {
  #   defaultLocale = "en_US.UTF-8";
  #   extraLocaleSettings.LC_ALL = "en_US.UTF-8";
  #   supportedLocales = [ "all" ];
  # };
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
