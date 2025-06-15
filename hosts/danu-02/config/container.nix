{ pkgs, lib, ... }:
{
  # virtualisation = {
  #   containers.enable = true;
  #   oci-containers.backend = "docker";
  #   docker = {
  #     enable = true;
  #     storageDriver = "btrfs";
  #     rootless.enable = true;
  #     rootless.setSocketVariable = true;
  #   };

  #   containers.storage.settings = {
  #     storage = {
  #       driver = "btrfs";
  #       runroot = "/run/containers/storage";
  #       graphroot = "/var/lib/containers/storage";
  #       options.overlay.mountopt = "nodev,metacopy=on";
  #     };
  #   };
  # };

  # environment.systemPackages = with pkgs; [
  #   dive
  # ];

  # # Add 'newuidmap' and 'sh' to the PATH for users' Systemd units.
  # # Required for Rootless podman.
  # systemd.user.extraConfig = ''
  #   DefaultEnvironment="PATH=/run/current-system/sw/bin:/run/wrappers/bin:${lib.makeBinPath [ pkgs.bash ]}"
  # '';
}
