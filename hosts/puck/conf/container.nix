{ pkgs, lib, ... }:
{
  # This is added for more rootless controls
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "btrfs";
      runroot = "/run/containers/storage";
      graphroot = "/var/lib/containers/storage";
      options.overlay.mountopt = "nodev,metacopy=on";
    };
  };
  virtualisation.docker = {
    storageDriver = "btrfs";
    enable = true;
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  '';
}
