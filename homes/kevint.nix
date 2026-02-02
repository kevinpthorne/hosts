{ config, pkgs, ... }:

{
  imports = [
    ./_modules/virt-manager.nix
  ];

  home.username = "kevint";
  home.homeDirectory = "/home/kevint";
  
  home.packages = with pkgs; [
    neofetch
    zip
    unzip
    gzip
    jq
    file
    which
    gnutar
    zstd
    gnupg
    ethtool
    pciutils
    usbutils
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Kevin Thorne";
      user.email = "me@kevinpthorne.com";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
	      vscodevim.vim
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
  };

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
