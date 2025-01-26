_: {
  # This is added for more rootless controls
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  virtualisation.podman = {
    enable = false;
    dockerSocket.enable = true;
    dockerCompat = true;
  };
  virtualisation.docker = {
    storageDriver = "btrfs";
    # rootless.setSocketVariable = true;
    # rootless.enable = true;
    enable = true;
  };
}
