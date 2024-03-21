{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      systems = import inputs.systems;

      perSystem = {
        pkgs,
        self',
        ...
      }: {
        packages = {
          default = self'.packages.prod;
          prod = pkgs.callPackage ./nix/blog.nix {iosevka = self'.packages.fonts;};
          staging = pkgs.callPackage ./nix/blog.nix {
            buildDrafts = true;
            buildFonts = false;
          };
          fonts = pkgs.callPackage ./nix/iosevka.nix {};
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            bun
            hugo
            just
            tailwindcss
            nix-output-monitor
            nodePackages.prettier
          ];
        };

        devShells.deploy = pkgs.mkShell {
          buildInputs = [pkgs.netlify-cli];
        };
      };

      flake.nixosConfigurations.blog = withSystem "x86_64-linux" (
        {
          config,
          system,
          ...
        }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs.packages = config.packages;
            modules = [./nix/server.nix];
          }
      );
    });

  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];

    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
