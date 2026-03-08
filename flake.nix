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
  };

  outputs =
    {
      nixpkgs,
      disko,
      sops-nix,
      lanzaboote,
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
    };
}
