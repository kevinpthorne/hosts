{ config, pkgs, ... }:

{
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
    userName = "Kevin Thorne";
    userEmail = "me@kevinpthorne.com";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
	vscodevim.vim
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
  };

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
