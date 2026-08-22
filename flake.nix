{
  description = "NixOS config";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    p2p-vpn.url = "github:kevinpthorne/p2p-vpn";

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      terranix,
      colmena,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        desktop1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/desktop1/configuration.nix
            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kevint = ./homes/kevint.nix;
            }
          ];
        };
        laptop4-builder = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.p2p-vpn.nixosModules.default
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/laptop4-builder/configuration.nix
            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kevint = ./homes/kevint.nix;
            }
          ];
        };
        bastion-g = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.p2p-vpn.nixosModules.default
            # Import the previous configuration.nix we used,
            # so the old configuration file still takes effect
            ./hosts/bastion-g/configuration.nix
            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kevint = ./homes/kevint.nix;
            }
          ];
        };
        "three.oc.kpt.link" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.p2p-vpn.nixosModules.default
            inputs.colmena.nixosModules.deploymentOptions
            inputs.disko.nixosModules.disko
            ./hosts/three.oc.kpt.link/configuration.nix
          ];
        };
        "one.oc.kpt.link" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.p2p-vpn.nixosModules.default
            inputs.colmena.nixosModules.deploymentOptions
            inputs.disko.nixosModules.disko
            ./hosts/one.oc.kpt.link/configuration.nix
          ];
        };
        "two.oc.kpt.link" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.p2p-vpn.nixosModules.default
            inputs.colmena.nixosModules.deploymentOptions
            inputs.disko.nixosModules.disko
            ./hosts/two.oc.kpt.link/configuration.nix
          ];
        };
      };

      darwinConfigurations.laptop4 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/laptop4/configuration.nix
        ];
        specialArgs = {
          flake = self;
        };
      };

      terranixConfigurations = {
        "cloudflare-global" = terranix.lib.terranixConfiguration {
          system = "aarch64-linux";
          modules = [ ./hosts/cloudflare-global/terraform.nix ];
        };
        "three.oc.kpt.link" = terranix.lib.terranixConfiguration {
          system = "aarch64-linux";
          modules = [ ./hosts/three.oc.kpt.link/terraform.nix ];
        };
        "one.oc.kpt.link" = terranix.lib.terranixConfiguration {
          system = "aarch64-linux";
          modules = [ ./hosts/one.oc.kpt.link/terraform.nix ];
        };
        "two.oc.kpt.link" = terranix.lib.terranixConfiguration {
          system = "aarch64-linux";
          modules = [ ./hosts/two.oc.kpt.link/terraform.nix ];
        };
      };

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "aarch64-linux"; };
          nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) self.nixosConfigurations;
          nodeSpecialArgs = builtins.mapAttrs (
            name: value: value._module.specialArgs
          ) self.nixosConfigurations;
        };
      }
      //
        builtins.mapAttrs
          (name: value: {
            imports = value._module.args.modules;
          })
          {
            # Only deploy the instances we want with colmena
            inherit (self.nixosConfigurations) "one.oc.kpt.link" "two.oc.kpt.link" "three.oc.kpt.link";
          };

      apps."aarch64-darwin" =
        let
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          terranixBin = terranix.packages."aarch64-darwin".terranix;
        in
        {
          "apply-cloudflare" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply-cloudflare" ''
                cd hosts/cloudflare-global
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform apply
              ''
            );
          };
          "destroy-cloudflare" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "destroy-cloudflare" ''
                cd hosts/cloudflare-global
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform destroy
              ''
            );
          };
          "apply-three-oc" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply-three-oc" ''
                cd hosts/three.oc.kpt.link
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform apply
              ''
            );
          };
          "destroy-three-oc" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "destroy-three-oc" ''
                cd hosts/three.oc.kpt.link
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform destroy
              ''
            );
          };
          "apply-one-oc" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply-one-oc" ''
                cd hosts/one.oc.kpt.link
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform apply
              ''
            );
          };
          "destroy-one-oc" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "destroy- -oc" ''
                cd hosts/one.oc.kpt.link
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform destroy
              ''
            );
          };
          "apply-two-oc" = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "apply-two-oc" ''
                cd hosts/two.oc.kpt.link
                ${terranixBin}/bin/terranix terraform.nix > config.tf.json
                ${pkgs.terraform}/bin/terraform init
                ${pkgs.terraform}/bin/terraform apply
              ''
            );
          };
        };
    };
}
