# This file should match the NixOS configuration in
# `nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix`
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  virtualisation.virtualbox.guest.enable = true;

  boot.growPartition = true;
  boot.loader.grub.device = "/dev/sda";
}
