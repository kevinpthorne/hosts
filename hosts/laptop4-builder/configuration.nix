# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../_modules/kevint-defaults.nix
    ./../_modules/dev.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "laptop4-builder"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # fix for home-manager
  programs.dconf.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kevint = {
    isNormalUser = true;
    description = "Kevin Thorne";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.p2p-vpn = {
    enable = true;
    mode = "endpoint";
    cluster = "bastion-vpn";

    # The VPN virtual subnet IP assigned to this node
    tunIp = "10.255.255.254/24";
    advertise = "192.168.64.4/24";

    # The Multiaddr of the bootstrap relay
    relay = "/ip4/54.211.99.58/udp/4002/quic-v1/p2p/QmZYJRws1XENarW52qwjDzMrrLAWRUAhPqBoRMZSrMaDpx";

    # Required private keys (absolute paths on the host managed via sops-nix/agenix)
    dataKeyPath = "/var/keys/p2p-vpn/data.key";
    identityPath = "/var/keys/p2p-vpn/identity.key";

    # Optional PKI enforcement (Public info embedded as strings)
    caKey = ''
      -----BEGIN ML-DSA-87 PUBLIC KEY-----
      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
      -----END ML-DSA-87 PUBLIC KEY-----
    '';
    nodeSig = ''
      -----BEGIN ML-DSA-87 SIGNATURE-----
      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
      xj1OVF5vn8nQ4eMNFx8nLTxBSw==
      -----END ML-DSA-87 SIGNATURE-----
      -----BEGIN ML-DSA-87 ROUTING SIGNATURE-----
      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
      AAAAAAAAAAAAAAAGDhIdJSwuNQ==
      -----END ML-DSA-87 ROUTING SIGNATURE-----
    '';
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.system-features = [
    "kvm"
    "nixos-test"
    "big-parallel"
    "benchmark"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
