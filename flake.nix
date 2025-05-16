{
  inputs = {
    # TODO: switch to 25.05 once released
    nixpkgs.url = "nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      kyubey = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./system
          ./system/kyubey

          disko.nixosModules.disko

          ({ ... }: {
            networking.hostName = "kyubey";
          })
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
          ./services/sing-box

          ({ ... }: {
            networking = {
              hostName = "moeka";
              domain = "0iq.dev";
            };
          })
        ];
      };
    };
  };
}
