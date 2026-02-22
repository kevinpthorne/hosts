{ ... }:
{
    # Host share
    fileSystems."/mnt/share" = {
        device = "share";
        fsType = "9p";
        options = [ "rw" "nofail" "trans=virtio" "version=9p2000.L" "_netdev" "auto" ];
    };
    # fix perms
    fileSystems."/home/kevint/share" = {
        device = "/mnt/share";
        fsType = "fuse.bindfs";
        options = [ "map=501/1000:@20/@1000" "_netdev" "nofail" "auto" ];
        depends = [ "/mnt/share" ];
    };
}