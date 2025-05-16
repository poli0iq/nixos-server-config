{ ... }: {
  disko.devices.disk.nvme0n1 = {
    type = "disk";
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          label = "EFI";
          name = "ESP";
          size = "256M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "defaults"
            ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            extraOpenArgs = [ "--allow-discards" ];
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
