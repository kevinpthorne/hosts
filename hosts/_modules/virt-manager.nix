{ pkgs, ...}:
{

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "kevint" ];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

}
