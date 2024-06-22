{
  disks ? [ "/dev/mmcblk1" ],
  ...
}:
{
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # mountpoint = "/media/btrfsroots/root";
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "@rootfs" = {
                    mountpoint = "/";
                  };
                  # Subvolume name is the same as the mountpoint
                  "@home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "@nix" = {
                    mountOptions = [
                      "noatime"
                      "compress-force=zstd:1"
                      "ssd"
                      "space_cache=v2"
                      "commit=15"
                    ];
                    mountpoint = "/nix";
                  };
                  # "@log" = {
                  #   mountOptions = [
                  #     "noatime"
                  #     "compress-force=zstd:1"
                  #     "ssd"
                  #     "space_cache=v2"
                  #     "commit=15"
                  #   ];
                  #   mountpoint = "/var/log";
                  # };
                };
              };
            };
          };
        };
      };
    };
  };
}
