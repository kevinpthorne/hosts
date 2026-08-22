{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Anti-bricking measures: ensure user has sudo access without a password
  users.users.kevint.extraGroups = [ "wheel" ];
  security.sudo.wheelNeedsPassword = false;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
