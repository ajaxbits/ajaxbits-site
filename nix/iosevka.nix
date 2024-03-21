{
  pkgs,
  lib,
}: let
  configFile = ../iosevka.toml;
in
  pkgs.buildNpmPackage rec {
    pname = "IosevkaAjaxbits";
    version = "27.3.5";

    nodejs = pkgs.nodejs_20;
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
      npm run build --no-update-notifier -- --jCmd=$NIX_BUILD_CORES --verbose=9 woff2::$pname
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      fontdir="$out/woff2"
      install -d "$fontdir"
      install "dist/$pname/woff2"/* "$fontdir"
      runHook postInstall
    '';

    enableParallelBuilding = true;
  }
