{
  pkgs,
  lib,
  system,
  buildDrafts ? false,
  buildFonts ? true,
  iosevka ? null,
  ...
}: let
  inherit (lib) concatStringsSep optional optionals;
  inherit (lib.fileset) difference gitTracked toSource unions;

  root = ../.;

  originalSource = gitTracked root;
  additionalIgnores = unions [
    ../flake.nix
    ../flake.lock
    ../.vscode
    ../.prettierrc
    ../bun.lockb
    ../garnix.yaml
    ../justfile
  ];

  src = toSource {
    inherit root;
    fileset = difference originalSource additionalIgnores;
  };

  nodeDeps = pkgs.mkYarnModules {
    pname = "ajaxbitsNodeModules";
    packageJSON = ../package.json;
    yarnLock = ../yarn.lock;
    version = "0.0.0";
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
      buildInputs = with pkgs;
        [
          hugo
          git
          nodePackages.prettier
          tailwindcss
        ]
        ++ lib.optionals stdenv.isDarwin [pkgs.openssl];
      buildPhase = ''
        runHook preBuild

        ${buildFontsCommand}

        cp -r ${nodeDeps}/node_modules ./.
        tailwindcss -i assets/css/main.css -o static/css/styles.css

        ${buildCommand}

        prettier -w public '!**/*.{js,css}'

        runHook postBuild
      '';
      installPhase = "cp -r public $out";
    }
