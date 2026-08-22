{ config, lib, pkgs, ... }:

let
  cfg = config.services.discord-alerts;
in
{
  options.services.discord-alerts = {
    enable = lib.mkEnableOption "discord alerts for warnings";
    webhookKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/keys/discord/webhook";
      description = "Path to the discord webhook URL";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.discord-alert-monitor = {
      description = "Monitor system state and alert to Discord";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [ curl gawk systemd jq coreutils ];
      script = ''
        STATE_FILE="/var/lib/discord-alerts/failed-units"
        mkdir -p /var/lib/discord-alerts
        touch $STATE_FILE
        
        while true; do
          if [ -f "${cfg.webhookKeyFile}" ]; then
            WEBHOOK_URL=$(cat "${cfg.webhookKeyFile}")
            
            # Check failed units
            FAILED_UNITS=$(systemctl list-units --state=failed --no-pager --no-legend | awk '{print $1}' | sort)
            OLD_FAILED_UNITS=$(cat $STATE_FILE)
            
            if [ "$FAILED_UNITS" != "$OLD_FAILED_UNITS" ] && [ -n "$FAILED_UNITS" ]; then
                # New failed units
                MSG="🚨 **Systemd Service Failures on $(hostname)**\n\`\`\`\n$FAILED_UNITS\n\`\`\`"
                JSON=$(jq -n --arg content "$MSG" '{"content": $content}')
                curl -s -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"
                
                echo "$FAILED_UNITS" > $STATE_FILE
            elif [ -z "$FAILED_UNITS" ] && [ -n "$OLD_FAILED_UNITS" ]; then
                # Recovered
                MSG="✅ **Systemd Services Recovered on $(hostname)**"
                JSON=$(jq -n --arg content "$MSG" '{"content": $content}')
                curl -s -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"
                echo "" > $STATE_FILE
            fi
            
            # Disk space
            DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
            DISK_STATE="/var/lib/discord-alerts/disk-alert"
            if [ "$DISK_USAGE" -ge 90 ]; then
                if [ ! -f "$DISK_STATE" ]; then
                    MSG="⚠️ **High Disk Usage on $(hostname)**\nDisk usage is at ''${DISK_USAGE}%"
                    JSON=$(jq -n --arg content "$MSG" '{"content": $content}')
                    curl -s -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"
                    touch "$DISK_STATE"
                fi
            else
                if [ -f "$DISK_STATE" ]; then
                    MSG="✅ **Disk Usage Normalized on $(hostname)**\nDisk usage is at ''${DISK_USAGE}%"
                    JSON=$(jq -n --arg content "$MSG" '{"content": $content}')
                    curl -s -H "Content-Type: application/json" -d "$JSON" "$WEBHOOK_URL"
                    rm -f "$DISK_STATE"
                fi
            fi
            
          fi
          
          sleep 300
        done
      '';
    };
  };
}
