{
  disks ? [ "/dev/nvme0n1" ],
  ...
}:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "2048M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@rootfs" = {
                    mountpoint = "/";
                  };
                  "@home" = {
                    mountOptions = [
                      "noatime"
                      "compress-force=zstd:1"
                      "space_cache=v2"
                      "commit=15"
                    ];
                    mountpoint = "/home";
                  };
                  "@home/custodian" = { };
                  "@nix" = {
                    mountOptions = [
                      "noatime"
                      "compress-force=zstd:1"
                      "space_cache=v2"
                      "commit=15"
                    ];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
