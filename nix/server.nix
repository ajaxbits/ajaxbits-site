{packages, ...}: let
  port = 80;
in {
  services.static-web-server = {
    enable = true;
    root = packages.prod;
    listen = "[::]:${toString port}";
  };
  networking = {
    hostName = "blog";
    firewall.allowedTCPPorts = [port];
  };

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  boot.loader.grub.device = "/dev/sda";
}
