{ pkgs, ... }:
{
    # Host share
    boot.initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "virtio_blk"
    ];
    fileSystems."/mnt/share" = {
        device = "share";
        fsType = "virtiofs";
        options = [ "rw" "nofail" ];
    };
}
