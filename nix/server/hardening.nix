{lib, ...}: {
  networking.firewall.enable = true;
  security.sudo.enable = false;
  environment.defaultPackages = lib.mkForce [];
}
