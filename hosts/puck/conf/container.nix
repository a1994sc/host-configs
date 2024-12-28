_: {
  # This is added for more rootless controls
  systemd.services."user@".serviceConfig.Delegate = "memory pids cpu cpuset";

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };
}