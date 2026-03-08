{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./disko.nix
  ];

  sops = {
    defaultSopsFile = ../../secrets/suzuha.yml;
    secrets.poli_suzuha_password.neededForUsers = true;
  };

  users.users.poli.hashedPasswordFile = config.sops.secrets.poli_suzuha_password.path;

  environment.systemPackages = [ pkgs.sbctl ];

  boot.initrd = {
    # Network card driver
    availableKernelModules = [ "igb" ];

    systemd = {
      enable = true;
      users.root.shell = "/bin/systemd-tty-ask-password-agent";
      network = {
        enable = true;
        networks."10-eno1" = {
          matchConfig.Name = "eno1";
          networkConfig.DHCP = "yes";
        };
      };
    };

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users.poli.openssh.authorizedKeys.keys;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # Second ESP on the second disk (mirrors the main one)
    extraEfiSysMountPoints = [ "/boot2" ];
    autoGenerateKeys.enable = true;
    # Expected to reboot two times total
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };
}
