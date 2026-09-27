{
  config,
  pkgs,
  lib,
  ...
}:

let
  caPubKey = ''
    -----BEGIN ML-DSA-87 PUBLIC KEY-----
    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
    -----END ML-DSA-87 PUBLIC KEY-----
  '';
in
{
  imports = [
    ../_modules/kevint-defaults.nix
    ../_modules/oci-hardware.nix
    ../_modules/discord-alerts.nix
    ../_modules/secure-ddns.nix
  ];

  networking.hostName = "one-oc";
  networking.domain = "kpt.link";

  services.secure-ddns.enable = true;

  services.p2p-vpn = {
    enable = true;
    mode = "relay";
    cluster = "bastion-vpn";
    identityPath = "/var/keys/p2p-vpn/identity.key";
    extDns = "one.oc.kpt.link";

    caKey = caPubKey;

    nodeSig = ''
      -----BEGIN ML-DSA-87 SIGNATURE-----
      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
      /AAAAAAAAAAAAAAHDxkfKDM3QQ==
      -----END ML-DSA-87 SIGNATURE-----
    '';
  };

  users.users.kevint = {
    openssh.authorizedKeys.keys = [
      (import ../_modules/terraform.nix).sshKey
    ];
  };

  deployment = {
    targetHost = "one.oc.kpt.link";
    targetUser = "kevint";
    keys = {
      "api-token" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/one.oc.kpt.link/cloudflare-api-token.key";
        destDir = "/var/keys/cloudflare";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
      "discord-webhook" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/one.oc.kpt.link/discord-webhook.key";
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

  services.anycast-edge = {
    enable = true;
    manifestKey = (builtins.readFile ./anycast-manifest.signed.b64);
    caPubKey = caPubKey;
    identityKey = "/var/keys/p2p-vpn/identity.key";
    listenP2P = "/ip4/0.0.0.0/udp/4003/quic-v1";
  };

  system.stateVersion = "24.11";
}
