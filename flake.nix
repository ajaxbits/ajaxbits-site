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
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      perSystem = {
        pkgs,
        system,
        self',
        ...
      }: {
        packages = {
          default = self'.packages.prod;
          prod = pkgs.callPackage ./nix/blog.nix {};
          staging = pkgs.callPackage ./nix/blog.nix {buildDrafts = true;};
          fonts = pkgs.callPackage ./nix/iosevka.nix {};
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            hugo
            just
            nixd
            nodePackages.prettier
          ];
        };
      };
    };
}
