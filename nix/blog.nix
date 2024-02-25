{
  pkgs,
  lib,
  buildDrafts ? false,
  buildFonts ? true,
  iosevka ? null,
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
    buildInputs = with pkgs; [nodePackages.prettier];
    buildPhase = ''
      ${buildFontsCommand}
      ${buildCommand}
      ${pkgs.nodePackages.prettier}/bin/prettier -w public '!**/*.{js,css}'
    '';
    installPhase = "cp -r public $out";
  }
