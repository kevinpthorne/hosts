{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../_modules/kevint-defaults.nix
    ../_modules/oci-hardware.nix
    ../_modules/discord-alerts.nix
    ../_modules/secure-ddns.nix
  ];

  networking.hostName = "three-oc";
  networking.domain = "kpt.link";

  services.secure-ddns.enable = true;

  services.p2p-vpn = {
    enable = true;
    mode = "relay";
    cluster = "bastion-vpn";
    identityPath = "/var/keys/p2p-vpn/identity.key";
  };

  users.users.kevint = {
    openssh.authorizedKeys.keys = [
      (import ../_modules/terraform.nix).sshKey
    ];
  };

  deployment = {
    targetHost = "three.oc.kpt.link";
    keys = {
      "api-token" = {
        keyFile = "./hosts/three.oc.kpt.link/cloudflare-api-token.key";
        destDir = "/var/keys/cloudflare";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
      "discord-webhook" = {
        keyFile = "./hosts/three.oc.kpt.link/discord-webhook.key";
        destDir = "/var/keys/discord";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
    };
  };

  services.discord-alerts = {
    enable = true;
    webhookKeyFile = "/var/keys/discord/discord-webhook";
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 4002 ];
  networking.firewall.allowedUDPPorts = [ 4002 ];

  system.stateVersion = "24.11";
}
