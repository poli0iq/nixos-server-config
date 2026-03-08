{ ... }:
{
  disko.devices.disk = {
    # Devices will be mounted and formatted in alphabetical order,
    # and btrfs can only mount raids when all devices are present.
    # So we define an "empty" luks device on the first disk,
    # and the actual btrfs raid on the second disk, and the name of these entries matters!
    disk1 = {
      type = "disk";
      device = "/dev/nvme0n1";

      content = {
        type = "gpt";

        partitions = {
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
                "nofail" # Boot even if this disk fails
              ];
            };
          };

          luks = {
            name = "crypt1";
            size = "100%";
            content = {
              type = "luks";
              name = "crypt1";
              passwordFile = "/tmp/secret.key";
              settings.allowDiscards = true;
            };
          };
        };
      };
    };

    disk2 = {
      type = "disk";
      device = "/dev/nvme1n1";

      content = {
        type = "gpt";

        partitions = {
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot2";
              mountOptions = [
                "umask=0077"
                "nofail" # Boot even if this disk fails
              ];
            };
          };

          luks = {
            name = "crypt2";
            size = "100%";
            content = {
              type = "luks";
              name = "crypt2";
              passwordFile = "/tmp/secret.key";
              settings.allowDiscards = true;

              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-d raid1"
                  "-m raid1"
                  "/dev/mapper/crypt1"
                ];

                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "noatime"
                      "discard=async"
                      "compress=zstd"
                      "degraded" # Mount even if one disk fails
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "noatime"
                      "discard=async"
                      "compress=zstd"
                      "degraded"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "noatime"
                      "discard=async"
                      "compress=zstd"
                      "degraded"
                    ];
                  };
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "noatime"
                      "discard=async"
                      "compress=zstd"
                      "degraded"
                    ];
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
