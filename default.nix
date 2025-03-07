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
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.comin.nixosModules.comin
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    settings/certs
  ];

  age.rekey = {
    masterIdentities = [ ./public/puck.pub ];
    storageMode = "local";
    localStorageDir = ./. + "/hosts/${config.networking.hostName}/secrets";
    extraEncryptionPubkeys = [
      "age1yubikey1q20jh97qrk9kspzfmh4hrs8qgvuq34lvhm2pum9dae7p97gq78tsghyyha3"
      "age1yubikey1qf42tcrzealy89zpmat6c9fzza9pgt8f3nwl42pvj7sk7lllf623vmjq30d"
      "age1yubikey1q0kv8am08zj3pdakl8407xd8j0qxxytzwqx09vrtk64dsw2r5qragk5kd4f"
      "age1wjqegc62gpyvp4yfdqfk4vclfgdh3awlv03rgthcje398a860p7qpglp6w"
      "age1tp5ln7rhy9y0w7lgtamtgjn4w4sajlm36fj0le4smf3hf0hlf4ysq03uhh"
      "age1758tal2rl0ew693xt6l2ffwnrua33sxr6tc4ta3utu639ldfq53szvgm0g"
      "age1q5urgt9hszq2j9p2qtprl853w6gcy9wapzt73r73xmjla4zhq98scpl8rm"
    ];
  };

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
