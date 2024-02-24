{
  pkgs,
  lib,
  buildDrafts ? false,
  ...
}: let
  inherit (lib) concatStringsSep optional;
  inherit (lib.fileset) difference gitTracked toSource unions;

  additionalIgnores = unions [
    ./flake.nix
    ./flake.lock
    ./.vscode
  ];

  src = toSource {
    root = ./.;
    fileset = difference (gitTracked ./.) additionalIgnores;
  };

  buildCommand = concatStringsSep " " (
    ["${pkgs.hugo}/bin/hugo"]
    ++ optional buildDrafts "--buildDrafts"
  );
in
  pkgs.stdenv.mkDerivation {
    inherit src;
    name = "ajaxbits";
    buildInputs = with pkgs; [nodePackages.prettier];
    buildPhase = ''
      ${buildCommand}
      ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
    '';
    installPhase = "cp -r public $out";
  }
