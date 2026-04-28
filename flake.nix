{
  description = "jagregory home-manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    workmux.url = "github:raine/workmux";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, workmux, ... }:
    let
      mkHome = system: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit username workmux;
            unstable = nixpkgs-unstable.legacyPackages.${system};
          };
        };
    in {
      homeConfigurations = {
        jag = mkHome "aarch64-darwin" "jag";
        dev = mkHome "x86_64-linux" "dev";
      };
    };
}
