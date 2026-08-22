sudo nixos-rebuild switch --flake .#desktop1

sudo nixos-rebuild switch --flake .#laptop4-builder

sudo darwin-rebuild switch --flake .#laptop4

## Provisioning New Cloud Hosts

The configurations for `one.oc.kpt.link`, `two.oc.kpt.link`, and `three.oc.kpt.link` include both Terraform configuration to provision the cloud infrastructure and NixOS configurations for the OS.

### 1. Authenticate with Oracle Cloud

Before running Terraform, ensure you are authenticated with OCI by running the following command to start an interactive session:

```bash
nix shell nixpkgs#oci-cli -c oci session authenticate
```

### 2. Provision Infrastructure with Terraform

Navigate to the root directory and run the deployment app for the host. For example, to provision `three.oc.kpt.link`:

```bash
nix run .#apply-three-oc
```

Provide the tenant/compartment OCID and the SSH CIDR.

### 3. Install NixOS with nixos-anywhere

Once the infrastructure is up, use `nixos-anywhere` to install NixOS over the initial Ubuntu boot image. Replace `<IP_ADDRESS>` with the public IP of the newly provisioned instance.

```bash
ssh-add ~/.ssh/deployment
nix run github:nix-community/nixos-anywhere -- --build-on remote --flake .#three.oc.kpt.link opc@<IP_ADDRESS>
```
*Note: You will need to deploy the `/var/keys/cloudflare/api-token` secret using colmena or your preferred secrets management tool after the initial deployment.*
