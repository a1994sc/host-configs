{ pkgs, lib, ... }:
{
  # This is added for more rootless controls
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  # keep-sorted start block=yes case=no
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
    rootless.enable = true;
    enable = true;
  };
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  # keep-sorted end

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  '';
}
