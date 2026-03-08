{
  inputs = {
    # TODO: switch to 26.05 once released
    nixpkgs.url = "nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      sops-nix,
      lanzaboote,
      deploy-rs,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        suzuha = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./system
            ./system/suzuha

            disko.nixosModules.disko
            sops-nix.nixosModules.default
            lanzaboote.nixosModules.lanzaboote

            (
              { ... }:
              {
                networking = {
                  hostName = "suzuha";
                  domain = "host.0iq.dev";
                };
              }
            )
          ];
        };

        moeka = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./system
            ./system/moeka

            disko.nixosModules.disko
            sops-nix.nixosModules.default

            ./services/acme
            ./services/nginx-redirects

            (
              { ... }:
              {
                networking = {
                  hostName = "moeka";
                  domain = "host.0iq.dev";
                };
              }
            )
          ];
        };
      };

      deploy = {
        sshUser = "poli";
        user = "root";
        sudo = "sudo -u";
        remoteBuild = true;

        nodes.suzuha = with self.nixosConfigurations; {
          hostname = with suzuha.config.networking; "${hostName}.${domain}";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos suzuha;
        };

        nodes.moeka = with self.nixosConfigurations; {
          hostname = with moeka.config.networking; "${hostName}.${domain}";
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos moeka;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
