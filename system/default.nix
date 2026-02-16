{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  sops = {
    defaultSopsFile = ../secrets/keys.yml;
    secrets.poli_password.neededForUsers = true;
    secrets.spaceship_api_key = { };
    secrets.spaceship_api_secret = { };
  };

  users.users.poli = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.poli_password.path;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1uUmneJb2GH7+NsZfjMz2tmoo1aBaXzuuwKLeewCJG poli@madoka"
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    neovim
    curl
    wget
    htop
    git
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    #ports = [ 222 ];
    settings = {
      #PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Let's just trust the security
  security.sudo.wheelNeedsPassword = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
