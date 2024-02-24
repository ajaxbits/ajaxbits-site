{
  pkgs,
  lib,
}: let
  configFile = ../iosevka.toml;
in
  pkgs.buildNpmPackage rec {
    pname = "IosevkaAjaxbits";
    version = "27.3.5";

    src = pkgs.fetchFromGitHub {
      owner = "be5invis";
      repo = "iosevka";
      rev = "v${version}";
      hash = "sha256-dqXr/MVOuEmAMueaRWsnzY9MabhnyBRtLR9IDVLN79I=";
    };

    npmDepsHash = "sha256-bux8aFBP1Pi5pAQY1jkNTqD2Ny2j+QQs+QRaXWJj6xg=";

    nativeBuildInputs = with pkgs;
      [ttfautohint-nox]
      ++ lib.optionals stdenv.isDarwin [pkgs.darwin.cctools];

    configurePhase = ''
      runHook preConfigure
      cp ${configFile} private-build-plans.toml
      runHook postConfigure
    '';

    buildPhase = ''
      export HOME=$TMPDIR
      runHook preBuild
      npm run build --no-update-notifier -- --verbose=9 webfont::$pname
      runHook postBuild
    '';

    # installPhase = ''
    #   runHook preInstall
    #   fontdir="$out/share/fonts/truetype"
    #   install -d "$fontdir"
    #   install "dist/$pname/ttf"/* "$fontdir"
    #   runHook postInstall
    # '';

    enableParallelBuilding = true;
  }
