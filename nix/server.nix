{packages, ...}: let
  port = 8787;
in {
  services.static-web-server = {
    enable = true;
    root = packages.prod;
  };
  networking = {
    hostname = "blog";
    firewall.allowedTCPPorts = [port];
  };
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  boot.loader.grub.device = "/dev/sda";
}
