{
  tier,
  packages,
  ...
}: let
  port = 80;
in {
  imports = [
    ./hardening.nix
    ./vpsConfig.nix
  ];

  services.static-web-server = {
    enable = true;
    root = packages.${tier};
    listen = "[::]:${toString port}";
  };
  networking.firewall.allowedTCPPorts = [port];
}
