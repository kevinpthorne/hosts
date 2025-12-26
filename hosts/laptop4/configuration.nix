{ flake, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
    ];

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # Enable alternative shell support in nix-darwin.
    programs.fish.enable = true;

    # Set Git commit hash for darwin-version.
    system.configurationRevision = flake.rev or flake.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 5;
}