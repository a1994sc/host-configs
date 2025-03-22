{ config, pkgs, ... }:

{
  ## Create a user "unifi" and a group for it

  users.groups.omni = {
    name = "omni";
    gid = 917; # I setup UID/GID manually since I refer to those later
  };

  users.users.omni = {
    group = "omni";
    uid = 1917;
    linger = true;
    isNormalUser = true;
    description = "Omni Controller";
    extraGroups = [ "podman" ];
    shell = pkgs.bash;
  };

  nix.settings.allowed-users = [ "omni" ];

  systemd.tmpfiles.rules = [
    ''v "${config.users.users.omni.home}/omni/etcd" 0770 omni omni''
    ''v "${config.users.users.omni.home}/omni/certs" 0770 omni omni''
  ];

  home-manager.users.omni =
    { pkgs, ... }:
    {
      programs.bash.enable = true;
      services.podman = {
        enable = true;
        autoUpdate.enable = true;
      };

      systemd.user.services.podman-pod-omni = {
        Unit = {
          Description = "Start podman 'omni' pod";
          Wants = [ "network-online.target" ];
          Requires = [ ];
          After = [ "network-online.target" ];
        };
        Install = {
          WantedBy = [ ];
        };
        Service = {
          Type = "forking";
          ExecStartPre = [
            # This is needed for the Pod start automatically
            "${pkgs.coreutils}/bin/sleep 3s"
            ''
              -${pkgs.podman}/bin/podman pod create \
                --replace \
                --network=pasta \
                --userns=host \
                --label=PODMAN_SYSTEMD_UNIT="podman-pod-omni.service" \
                omni
            ''
          ];
          ExecStart = "${pkgs.podman}/bin/podman pod start omni";
          ExecStop = "${pkgs.podman}/bin/podman pod stop omni";
          RestartSec = "1s";
        };
      };
      services.podman.containers = {
        omni-talos = {
          # image = "ghcr.io/siderolabs/omni:v0.47.1";
          image = "docker.io/library/registry:2.8.3";
          description = "Start Omni (podman)";

          extraConfig = {
            Unit = {
              Wants = [ "network-online.target" ]; # This might be ignored
              Requires = [
                "podman-pod-omni.service"
              ];
              After = [
                "network-online.target"
                "podman-pod-omni.service"
              ];
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };

          autoStart = true;
          autoUpdate = "registry";
          extraPodmanArgs = [
            "--pod=omni"
            "--group-add=keep-groups"
          ];

          volumes = [
            "${config.users.users.omni.home}/omni/etcd:/_out/etcd"
            "${config.users.users.omni.home}/omni/certs:/certs:ro"
          ];
        };
      };
      home.stateVersion = "24.11";
    };
}
