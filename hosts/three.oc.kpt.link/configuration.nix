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

  networking.hostName = "three-oc";
  networking.domain = "kpt.link";

  services.secure-ddns.enable = true;

  services.p2p-vpn = {
    enable = true;
    mode = "relay";
    cluster = "bastion-vpn";
    identityPath = "/var/keys/p2p-vpn/identity.key";
    extDns = "three.oc.kpt.link";

    caKey = caPubKey;

    nodeSig = ''
      -----BEGIN ML-DSA-87 SIGNATURE-----
      YNprT371B2krMod7uOUuENdkK/t9iSzF03rELjmCvOfshL6JfPcjbzkJHzCFz0Hp
      i0xA7D2Uzr5x6rqpIqE+0J5RlzXyz5wTQT7npvVfFLOlNHs8PKiwA8PCLw7SggkN
      jhCMWc4rwkAg8/Ecz6nPhpWNPi3K56Hoc0HsYGi4D74e8HpU1eP3VB8pGk2+jGVc
      KLiziU7H6VT8iZFn5/vanRHiBHjKCXBv3Lxp6rKDN2p8trQ3tdsCzx08ovJo0RT3
      7mRkld7l8PF1bCA78gMWvmkIPq+f5XQFr4wn/4uVPLjsh1e1+0mysEmZAgF0ql9G
      eIeecTWh5AyvjCmMm5shgmS6HuGrGKfGj8o/lTzBQ8ho5cafByi3b7VsIyZ7vJTC
      HtA/0STfuwvX6VnCJd1hwHKkZqI6gh37dQ0ykG2nUBxzq2+E+OQO+KAsqTA9XuRw
      SMOkqtONRFzmvOOVjcnrifWeTahxH2Ow5tJcJheT4Dui/n3kTSpBnonJEJ4+6YDq
      9Gba6GVRvuyygiKq456eKlSyGeFxvyab2470NQakm2Un8atz+Oo6UHjMKo4JF7Ao
      iGrA/+QeCxOfdaFMuFS6iRtf4+he+RSet7SUdQ9GxVKOHZBoX4PdCxmf0Pb+IMCF
      8TFbP/3i8+eMedEini/LSfzEE7UnXZekQ31MCzb9iZNSm3zWWMX3iru5OmNxl1gs
      V2k5fX0Ys93jKMK6TM22OzU/tC74g1yPvw+ryamQsWiK7Y2LWxiv3e+3rf1Cu1C1
      HhHVAFiXqhDhasoMQghDQ68tFU+Y8Kyk0441gl5b7R7WcmWPbyRIt3MkAcCDZVMT
      Wwo+6p5+QldZNZFPir3JDczQF7ywsS0QhW0twP+iEnhg2D8Fpwq/D8ES3YbVt6+v
      Zms3flZ+G+zbnWtw/mFWzWfT5jHIvpQzFyrmCscOV7EWTQG160NTL70uhm8neJec
      UaFFhVh40QsA+Av8dyDPt4JeL34YiyT8E3wt734I87BLIKVH3wHF3mUhc/2pPeh0
      /XF3ZN78fzom2Ntc2dMBNO0rchUszVZLgNJlXdAFUYdQKzH9MZiYb/d7Q9sa0Hwm
      w+57rbtejYLQ7N4hUKv2vT6+RH/tMKmxjZbiNQyP5Mxj6nUyfly8xMqfDv1T6U1+
      ZtEWAo9Rw007SPnK5yAg1KOmbHIRaeuMUdM2pHANfsXIQUvNuf5IIK7gYuUmeUGG
      ge9Ai6QoCObXBOBfMgAFF+VY9JG6TvI9R7CgDoStgK25j8CFHMagsfzALfs4hNaK
      rgnKnloOulRlQ2eUPxKad0end9Y9bOPoJtWgCmZdNu2D8j3XhtCsdTRiAvOpszr2
      PXw6hf+iXJFeOr0BMde8ymSyuiQwpEIO223edSu2IRt0bGJD4xTi9o8CLsSTuhVz
      F8Ll8EPPtQ8jcNr1YnUuZoKAAW1RccNTnqtlEbFq+bfpRGvi3xD7w1emYHoaGoJ9
      jRRpEs4jDSJzDE667GOeIKZ0DSBjg4W6KzEBumRgtMEylcaKO+Vmehm7NWaFweXD
      oPujRuk3kjeLqKUiJCzt+wJjdvUfzITBrE/un7Kxk7/7ParyNoavJoVUAat64qm1
      DMN/FYQaT6ur/iSXtY0ke98V7Z0suUPwGPplVxhbQ+w4TXGP7WtpHeA/IC4eUaan
      Y3M4G3EHB5nkCX4pp+Cx73mjQTbX7rIDLa9kfCQgpBaHc00uglNOoswp2mYPK9tP
      kT0hjef8b0H4AMCU+QiDqelY4qm/JlOL62OlOvzU2gGnXYlIcU2ph7xM3hQksD6j
      GYZacuqCIkI89GRM9wkB3KIVxGH/c4rMFi/Zv7QiEL9pCq1tzSCjJzgMr9hVXMWl
      ojF61E7ALu16h+oIUA6hGEPMB+QMRzfeLKE7aBwtSibI6EPcoRvmiPEY5c1J7v1b
      SfLwA/XgIVYBx97Nf4ZC6/l8zvJz2XUjgGxkyCzPhC8qavFxz2aa1H2IoUqWYZye
      6qQzG8E0sjkyc6nUHHV7wAbst/Fu24/kMNozgALUIb8+zvR82OMpv2qbvI7FrRdE
      tyqkNHgXBCEVzaJAhdH1ZDGNMhl/NP1BhPaq5ndEbKCoJPz7MVITlxlkW0tZF1ng
      3B7KW0zQermdIjNXekkKEX3EBzRAYaEen7IpY3FRIF5PX0brIE7BfEKRxekjWFu0
      iOXot2CICgBEEPr90X5eoxxkrb7J+zyeXg3qX2lXkFneDxcKpYHYdceEFrj3mERI
      hj5/Ege2/QXBXkn21lBCOdGVgV0ShuvDdgoIgPg1qpaYbLSGGmiebf9aYb8NCSxE
      7YdoX+/t1ODY+Zf1OJweHBiSy+SBNdULWacwztdPBa5FtEegs/At8c1YnyBU/Mbz
      iC1d4m0xhjoP/185LvGR4WGvWwEnqJOXYzbRvy9u5WZ4SLRy0NrjI1DePzfOjlI+
      1NBfTWfahkmdTgs1Jedl1VxkX02rrXyJ8ZVrr7Eq4P6EXhDojJOWEf6idkThHX85
      8hqNTWcc6RK7SnA7nansQboL64LMEwzEAfN87jez3ThbZugrd+sO4U0fqZ6IbESS
      EWUkZ36D5lB0eSFlNTKKFDSIVUopwJoWfTdAvN2iH86MRhV9Kx+xJKkWkU3m/Zpx
      cQs9qmElNuTNTpyWdWt3HkjixHbPj5VZtxZu2NtVfClvB0v8KCol8f2I67cmF/Xc
      foB9/f9xVm3I2g4VaXAVFX3mm4Wrgw8z8hT8by4ejpadseProaJGXlq8VfA/lT7c
      E8q+HZAvMxE4+HNkC5jYoX44sRY5JOTuszpoWCESxoMaH2DrDhLp7TZZUnKUu77G
      HGA32MmF1MdufULj153Jid+GnNOOmcGl2rKzxAep0eTRtiT9/f9DYRyGkZX5KuZ1
      jiJ6gm5DRIfVxADbrpAPTbgpRort/AMnV4RdEVKNwskfo6VOXjhsmdeBaa1+OKie
      9y7KAs3ToDkBM44iFVr0oa3JvxVhzRPHnO5XZ8LsZTtdAyCka8pMhfQ1Eez4s0nK
      hXXnew4LXtsozr9Rha3FR5fnmggSuF/l2yb2xhTb9rWiM3fw0/2BcLadvqx6dzUe
      GcnXKOXI6jiYPehTxJGZVfTKQku6DwTh2p8+XwthbSMmzgGBGWkRGuxvHRAAPmWO
      9o0c5QM+tuQHykcdlpxAPvoHdjY2GM0oWPFV2QPg185MO+KR7sawDh3t9UhsuB/m
      7EPZT2EUyCPtLwoNTB/z7WwX5O7kS0R6KenJZsy/TPlNs5EQvcoR/NpWkafyN6PB
      TcrpHlaNm0i7dgByxq/XrDtMVUAwEuqLxsaVQXrVoRbW4TchyVrIB1v/5pIP6NPP
      jN7BKYw0pC4RlTEWQW7OXR21tP5He4LdvkYE7HgV9K97JXC+OnZ8gU2jC6JyqMvG
      ZsHX5mVz8aAX1Ww5qHaDmR2YEOolnHVfQLh8G4+oUs3qJn9HTRLDOqUE50s/dTW8
      F6SG18pY2YK8rs0Yc5J8dC2Q7XeaCupzVd1iO4lMciMefnxor/CbmU1E5crP2rdH
      l5zZcped/FKdRuUFWznQXWNWiFaKi0whg7nrxmhkcOmMEDNMhuwoZYKBWTnaMkwG
      aoULNUVno6jlOd1zP3iGCUNwKb+aSj3bWhAweSZzB5eveVxkYEJjbRso0pteAarR
      tg4+awFzZG4wa7mPjyKaG+m0s6HpYuPwz0ZgECxtslwhNVni2dfe7R1xysScvOeY
      RbAa2J1IxKSZdMXBCt7EbLnzj/2pQ6MYzOYn+TOquxJZU8bzQEH4Va2brV1bEGgp
      MZqavTk1lEj0x1wXnuOZLCu1k9pYQdas+9AmiwAwpGwD3uR2nrPYysQ/yuHeYhHK
      TDilF8OAO79ZoD+PW/rvJGNxKJNb0P1YKsUQxdXKawr+jtMNVpEWjxhooneudQuV
      5scFC07Awz1EIVvEGssbUcDTMd0CNX8lfrgaV7AVfisXhAZYgmucl0Z7Qp5fUhrZ
      fhYmUMOcN3Qh7pI1dixUbyZQBAp3hzWBbVwIAtmEyd6z0o+J57EoeyOUrpg9a0Rr
      mt3e1z6GMRVEJS5HzOY+MLrfGvXToj1tthIRewJ+dXVeRI3hLEo2zi3afbgV8JTa
      98w2OkMj89gQRawIcC5Tn8wZA5LIvx/6BkTtgAGD3xCg/M0QCfQzeA/xBykXJilr
      hH9GMNXBzKHG3lW87/fWBEgOGHM7lfxgLhHfIRGQBU4omtui3TpbY5K7ybEfD8BO
      7inVEqQPYK3+GE2viGfWAyOgLfE8qhMrvrS4QDlzjhCzghynom6SgqJD0jDN3+qb
      VsZrAyzMNH+5xLIj8cHq0MYnW1cVU6zqNZRjns7z5/Egb8IU1wZmSxhYb2hLRnnh
      smp4NL66j5ocIukxiLVcBD0IayL3LXPcBrsfdsFvSUPVJl96/KA5HIxuD/EIhUIH
      XC+hpIVyooe+k1dy3DnH5aDK4mBcVRtchoq1HeW+8gXgVpAF2qs5mzJTCNmLG9CU
      dU92PyFAC6BSBb/AAJs2N35BAagP/IHkQZmYoSn1Rao4O9a5yz//kHjRSWxH82Pj
      cANyjBOZKRPG+wx1BEFrGSdQJST6H1vRFCdKI1r/DDjTgXosgydXAzyFBWL9qc3h
      Lr4QkvvOeDMwqIvb2RdMmkfGC0J5JoGH2l0IVQbaIkQRRs6BOR7k3juroYTBkK6L
      iDBADqzvY4m/E//lrM4pkcNBwdeRb8JNKIQRRj14OCGyiPPWUfZjZLwHLW//2BjM
      fNWeR44uw8T8OrSWoEBVNCSTCqWgGjKWRPA398FdGh6FUO/NVANLhOYlYp5f7Kim
      oaBtR2kn//uadrlrrvZoTc/9KUUurhCvRLAGuJtYQJ/5UhLJwfQLjkTNj2pxuEqj
      Anyb1lINtqtrDHufoQMqsqGmigZE0C92r9VECbVIRnfk/1Fy7b2bHYkmvs/+Zq+j
      MEOXPKRo7dYpocbDuwe9b6m06a0m+VW44eNhsEemlDiMpp1E+w1TYjc+I+7JK6Jv
      m7JcFnJYXmt4MdCF+RGGPPBUd0tNzX9vQhcQNXN+BSyUxUF5yDilCK1Y96mGMFVz
      D8Rq9oYk/uSo+DJoXp7Kss3HaLz8kvIqgs5lPcvJeeNPpB+PFZjxKm/UihO70VMc
      R8X17ORqUETffKdAhHMLIy8kHU3TXnZhjrCLQySf6Yt8J5Xy+TDog0GU9UID64gY
      Nidfzzk0UZjm22nWUm48qbNqJma/unm5C6lzUcb55I00NxrFiGVrkR37bry4KZkg
      CTjOBS4nSn5lKxRAgYo4wJ00EyigdtAffLsa8OizPf2pMePNpp3WJK3uhXoeAT4P
      74qfvI/vwkEzl3XIfoyEPAvLvxNkVw5TCgpQDNICiq7h3Qo4usJ9TZy1lHL5EQ2J
      ZNppl6k/ZSNft1OkJCLoL2IknYDAw0FM/90Njnh0D50cvjrnWtjGAC/sys85etF5
      p1FBRkUyuUMwI9f0myuNs1lXzI1w09u7kReCH/woUTSdtNhAYp1AbammlZ75r+Gw
      WiVWcA/rnHrCrNyZefvU3z6IMa37mPsW345R6qGb7hvn9oA3ycJMLlt5LPpT67T3
      XOkW+Fwp1ucA/EHBbzBo2gIkjYSvYGMwHAiDprQ9VV1/jydDEuEAPmo89fB+G3x2
      fp7lhs3RtjvOqpao1iu7VU2/nM0WckiABN75Eg4NMOJBKUAZL0cOU7SfXwpvsfqB
      M28oj5yE4qqE2t9BsrycJs439qs+FLDe+ZxKAIbNBzQ6ADTYba8s6/NY7NEqqgG/
      8MQtYzvI1SYeId8LlNobj6NPzug2QS0FNVmEWj10gKf2dDyjshvVgu0o82ht+BEu
      epQUKBlbSaGgYEmLBqBPSpLHNS6mMckeZKd/987uI8pJt4l3CXWkizcHnskoQXS9
      HpqM3xYKSi2KRHh906HCaomQPfHxCOYLDJCoVKyq5CPMyCYRZZK02XlLTqmNz7tr
      TQki0R1nONnDconzN4V70kL8at0HfZgXr2yKRT/NYj5JHaW/9NyRJc6IBJkXwJoa
      91Djdp9Wr/0WD2GxEaCdNhATZzPMUw4Vcdkoi1VrE5hkfuwzXY2o1PdPcIO4u83Y
      5A5ojJYMP0tRXN/u7/giKDhGW5vc5x0lJ0lhZoaen6e/5/QmPYKFsgAAAAAAAAAA
      AAAAAAAAAAAAAAADCREVHiYzOA==
      -----END ML-DSA-87 SIGNATURE-----
    '';
  };

  users.users.kevint = {
    openssh.authorizedKeys.keys = [
      (import ../_modules/terraform.nix).sshKey
    ];
  };

  deployment = {
    targetHost = "three.oc.kpt.link";
    targetUser = "kevint";
    keys = {
      "api-token" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/three.oc.kpt.link/cloudflare-api-token.key";
        destDir = "/var/keys/cloudflare";
        permissions = "0400";
        uploadAt = "pre-activation";
      };
      "discord-webhook" = {
        keyFile = "/Users/kevint/vms/debian/hosts/hosts/three.oc.kpt.link/discord-webhook.key";
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
