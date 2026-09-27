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
    ../_modules/secure-ddns.nix
  ];

  networking.hostName = "two-oc";
  networking.domain = "kpt.link";

  services.secure-ddns.enable = true;

  services.p2p-vpn = {
    enable = true;
    mode = "relay";
    cluster = "bastion-vpn";
    identityPath = "/var/keys/p2p-vpn/identity.key";
    extDns = "two.oc.kpt.link";

    caKey = caPubKey;

    nodeSig = ''
      -----BEGIN ML-DSA-87 SIGNATURE-----
      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
      jpC9ztLqAAAAAAAIERohLzY8Rg==
      -----END ML-DSA-87 SIGNATURE-----
    '';
  };

  users.users.kevint = {
    openssh.authorizedKeys.keys = [
      (import ../_modules/terraform.nix).sshKey
    ];
  };

  deployment = {
    targetHost = "two.oc.kpt.link";
    targetUser = "kevint";
    keys = {
      "api-token" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/two.oc.kpt.link/cloudflare-api-token.key";
        destDir = "/var/keys/cloudflare";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
      "discord-webhook" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/two.oc.kpt.link/discord-webhook.key";
        destDir = "/var/keys/discord";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
    };
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
