{ config, lib, pkgs, modulesPath, ... }:

{
    
    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = "aarch64-darwin";  # Apple M chip
}