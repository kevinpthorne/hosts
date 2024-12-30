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

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
