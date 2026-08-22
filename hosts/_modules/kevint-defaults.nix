{ ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.variables.EDITOR = "vim";

  users.users.kevint.isNormalUser = true;
  nixpkgs.config.allowUnfree = true;
}
