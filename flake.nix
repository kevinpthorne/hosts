{
  description = "Desktop1 NixOS config";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gnome-fix.url = "github:LucasFA/.nixos/9cfda103f9781ad02af08b98efe04a61f3d7e7bc";
  };

  outputs = { self, nixpkgs, home-manager, gnome-fix, ... }@inputs: {
    nixosConfigurations.desktop1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./hosts/desktop1/configuration.nix
        <gnome-fix/hosts/slimbook-hero/gnome-fix.nix>
	# make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kevint = import ./homes/kevint.nix;
        }
      ];
    };
  };
}
