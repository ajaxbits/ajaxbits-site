{
  tier,
  packages,
  ...
}: let
  port = 8787;
in {
  imports = [
    ./hardening.nix
    ./vpsConfig.nix
  ];

  services.static-web-server = {
    enable = true;
    root = packages.${tier};
    listen = "localhost:${toString port}";
  };
  services.nginx = {
    enable = true;
    virtualHosts."_".locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${toString port}";
    };
  };
}
