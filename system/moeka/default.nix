{ config, ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  sops = {
    defaultSopsFile = ../../secrets/moeka.yml;
    secrets.poli_moeka_password.neededForUsers = true;
  };

  users.users.poli.hashedPasswordFile = config.sops.secrets.poli_moeka_password.path;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "172.16.0.1";
    interfaces = {
      ens3 = {
        ipv4.addresses = [
          {
            address = "193.135.137.176";
            prefixLength = 32;
          }
        ];
        ipv4.routes = [
          {
            address = "172.16.0.1";
            prefixLength = 32;
          }
        ];
      };
    };
  };
}
