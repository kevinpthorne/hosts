{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.secure-ddns;
in
{
  options.services.secure-ddns = {
    enable = mkEnableOption "Secure DDNS via Cloudflare Worker Proxy";

    proxyUrl = mkOption {
      type = types.str;
      description = "The URL of the Cloudflare worker proxy.";
      default = "https://ddns-proxy.kevinpthorne.workers.dev/";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to the file containing the secret token.";
      default = "/var/keys/cloudflare/api-token";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.secure-ddns = {
      description = "Secure DDNS Update";
      after = [ "network.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "secure-ddns-update" ''
          set -e
          TOKEN=$(cat "$CREDENTIALS_DIRECTORY/token" | tr -d '\n')
          OUT_FILE=$(mktemp)
          trap 'rm -f $OUT_FILE' EXIT

          res=$(${pkgs.curl}/bin/curl -w "%{http_code}" -s -o "$OUT_FILE" -X POST "${cfg.proxyUrl}" -H "Authorization: Bearer $TOKEN")
          if [ "$res" != "200" ]; then
            echo "DDNS update failed with status $res: $(cat $OUT_FILE)" >&2
            exit 1
          fi
          echo "DDNS update succeeded: $(cat $OUT_FILE)"
        '';
        User = "nobody";
        DynamicUser = true;
        LoadCredential = "token:${cfg.tokenFile}";
      };
    };

    systemd.timers.secure-ddns = {
      description = "Run secure-ddns every 5 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
        RandomizedDelaySec = "30s";
      };
    };
  };
}
