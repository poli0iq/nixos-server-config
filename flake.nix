{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations = {
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
                  domain = "0iq.dev";
                };
              }
            )
          ];
        };
      };
    };
}
