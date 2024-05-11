{
  config,
  pkgs,
  outputs,
  version,
  inputs,
  system,
  ...
}:
let
  inherit (inputs) agenix;
in
{
  imports = [
    agenix.nixosModules.age
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
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };
    settings = {
      max-jobs = "auto";
      auto-optimise-store = true;
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
  users = {
    extraUsers.ascii = {
      subUidRanges = [
        {
          startUid = config.users.users.ascii.uid * 10;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = config.users.users.ascii.uid * 10;
          count = 65536;
        }
      ];
    };
    users.ascii = {
      isNormalUser = true;
      description = "Allen Conlon";
      uid = 1000;
      extraGroups = [
        # keep-sorted start
        "dialout"
        "docker"
        "networkmanager"
        "wheel"
        # keep-sorted end
      ];
      openssh.authorizedKeys.keys = [
        # keep-sorted start
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACa5MIyu4mLLLc0D5Y0eOWV1JnvvSo68pDJAh4SyC1WyMVK1eOIlpyDlfFNu7wev8fPELJEwbT+pCsjH2FVU8qRNAH17nW1EBn9xWOX7rEnpxOp6X485+jeA0t/a2jB6e7Bcn86Xwa1tPEbIKS6eo530KMLagaCFpl9arv1SGWeh6/YAw== aconlon@puck.adrp.xyz"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF/R3bjaZYUB6cJe7jcexHc+n+zk+F+39SH55nHWk1uqX5h+/YSkDlDPl42QfVVcV/kyX21yv3zUO3zl6h+OsDltgH9+VggOJSvrYYWLx5vb9H3gH6y3yfc2V8Eyg6v4svSE2z6SbRmQw/bLmCcCU+C+oC74du/a/VJocT4ib706LMG2A== aconlon@omga.ardp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
        # keep-sorted end
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    # keep-sorted start prefix_order=staging,unstable,
    unstable.nh
    agenix.packages.${system}.agenix
    git
    htop
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
    };
  };
}
