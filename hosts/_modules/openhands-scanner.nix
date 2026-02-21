{ config, lib, pkgs, ... }:
{
  options.openhands-scanner = {
      enable = lib.mkEnableOption "Enable OpenHands Workspace Real-Time Anti-Virus Scanner";
      home = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/openhands";
      };
  };

  config = lib.mkIf config.openhands-scanner.enable {
    # 1. Enable ClamAV Anti-Virus Daemon and Signature Updater (freshclam)
    services.clamav.daemon.enable = true;
    services.clamav.updater.enable = true;

    # 2. Create the Real-Time Scanner Service
    systemd.services.openhands-scanner = {
      description = "OpenHands Workspace Real-Time Anti-Virus Scanner";
      wantedBy = [ "multi-user.target" ];
      
      # Ensure ClamAV is running before we start handing it files
      after = [ "clamav-daemon.service" "openhands.service" ];
      requires = [ "clamav-daemon.service" ];

      # Provide the necessary tools to the script
      path = with pkgs; [ inotify-tools clamav coreutils ];

      script = ''
        WORKSPACE="/var/lib/openhands/workspace"
        QUARANTINE="/var/lib/openhands/quarantine"

        # Ensure directories exist and secure the quarantine folder
        mkdir -p "$WORKSPACE" "$QUARANTINE"
        chmod 700 "$QUARANTINE"
        
        echo "Starting real-time malware monitor on $WORKSPACE..."

        # Listen for completed file writes (close_write) or files moved into the dir (moved_to)
        inotifywait -m -r -e close_write,moved_to "$WORKSPACE" --format "%w%f" | while read -r FILE; do
          
          # Only scan actual files, ignore directories
          if [ -f "$FILE" ]; then
            
            # Use `clamdscan` (daemon) rather than `clamscan` (standalone). 
            # The daemon keeps virus definitions in RAM, making scans take milliseconds.
            # --fdpass passes the file descriptor so ClamAV can read it regardless of ownership.
            if ! clamdscan --no-summary --fdpass "$FILE"; then
              
              echo "[!] MALWARE DETECTED [!]"
              echo "Infected file: $FILE"
              
              # Instantly strip it from the workspace so OpenHands can't execute it
              mv "$FILE" "$QUARANTINE/"
              echo "Moved to: $QUARANTINE"
              
            fi
          fi
        done
      '';

      serviceConfig = {
        Type = "simple";
        
        # We run this as root so it has the absolute authority to move any malicious file 
        # out of the directory, even if the Docker container created it with weird permissions.
        User = "root"; 
        
        # Keep the monitor running indefinitely
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}