{
  pkgs,
  lib,
  buildDrafts ? false,
  buildFonts ? true,
  iosevka ? null,
  ...
}: let
  inherit (lib) concatStringsSep optional;
  inherit (lib.fileset) difference gitTracked toSource union unions;

  root = ../.;

  originalSource = gitTracked root;
  additionalIgnores = unions [
    ../flake.nix
    ../flake.lock
    ../.vscode
  ];

  src = toSource {
    inherit root;
    fileset = difference originalSource additionalIgnores;
  };

  buildCommand = concatStringsSep " " (
    ["hugo"]
    ++ optional buildDrafts "--buildDrafts"
  );

  buildFontsCommand =
    if buildFonts
    then ''
      cp -r ${iosevka}/woff2/* static/fonts/.
    ''
    else "";
in
  assert buildFonts == true -> iosevka != null;
    pkgs.stdenv.mkDerivation {
      inherit src;
      name = "ajaxbits";
      buildInputs = with pkgs; [bun hugo git nodePackages.prettier tailwindcss];
      buildPhase = ''
        bun install
        ${buildFontsCommand}
        tailwindcss -i assets/css/main.css -o static/css/styles.css
        ${buildCommand}
        prettier -w public '!**/*.{js,css}'
      '';
      installPhase = "cp -r public $out";
    }
