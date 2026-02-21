{ config, pkgs, lib, ... }:
{
    imports = [
        ./transparent-proxy.nix
        ./openhands-scanner.nix
    ];

    options.openhands = {
        enable = lib.mkEnableOption "Enable OpenHands autonomous coding service";
        llmModel = lib.mkOption {
            type = lib.types.str;
            default = "gemini/gemini-3.1-pro-preview";
        };
        container = lib.mkOption {
            type = lib.types.str;
            default = "docker.openhands.dev/openhands/openhands:1.4";
        };
        secretsEnvFile = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/secrets/openhands.env";
        };
        home = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/openhands";
        };
        cpus = lib.mkOption {
            type = lib.types.str;
            default = "8.0";
        };
        mem = lib.mkOption {
            type = lib.types.str;
            default = "16g";
        };
    };

    config = let
        openhandsCidr = "172.18.0.0/16";
        openhandsDockernet = "openhands_net";
    in lib.mkIf config.openhands.enable {
        # 1. Create a dedicated service account and group
        users.groups.svc-openhands = {};
        users.users.svc-openhands = {
            isSystemUser = true;
            group = "svc-openhands";
            extraGroups = [ "docker" ]; # Required for OpenHands to spin up sandboxes
            home = "${config.openhands.home}";
        };

        # 2. Setup security
        transparent-proxy = {
            enable = true;
            ipCidr = openhandsCidr;
            allowedDomains = [
                ".googleapis.com"
                "github.com"

                # container reg
                "docker.all-hands.dev"

                # --- Go Package Management ---
                "proxy.golang.org"       # The default GOPROXY
                "sum.golang.org"         # The default checksum database
                "index.golang.org"       # Go module index
                "golang.org"             # Legacy package paths
                "gopkg.in"               # Very common Go package router (e.g., gopkg.in/yaml.v2)
                "go.googlesource.com"    # Host for golang.org/x/... extended packages
            ];
            dockernetName = openhandsDockernet;
        };
        openhands-scanner.enable = true;

        environment.systemPackages = with pkgs; [
            docker
        ];

        virtualisation.docker.enable = true;
        virtualisation.docker.rootless = {
            enable = true;
            setSocketVariable = true;
        };

        # 3. Define the OpenHands systemd service
        systemd.services.openhands = {
            description = "OpenHands AI Agent Service";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" "docker.service" "openhands-scanner.service" "my-redsocks.service" "docker.socket" ];
            requires = [ "docker.service" "docker.socket" ];

            # Ensure necessary state directories exist before starting
            preStart = ''
            mkdir -p ${config.openhands.home}/workspace
            mkdir -p ${config.openhands.home}/state
            '';

            serviceConfig = {
                Type = "simple";
                User = "svc-openhands";
                Group = "svc-openhands";
                
                StateDirectory = "openhands";
                WorkingDirectory = "${config.openhands.home}";

                # --- SECURE SECRET LOADING ---
                # Systemd reads this file as root before dropping privileges.
                # It will not be stored in the Nix store.
                EnvironmentFile = "${config.openhands.secretsEnvFile}";

                # Standard non-secret environment variables
                Environment = [
                    "LLM_MODEL=${config.openhands.llmModel}"
                    "WORKSPACE_BASE=${config.openhands.home}/workspace"
                ];

                # Launch via Docker. 
                # Passing `-e LLM_API_KEY` (without a value) securely forwards the 
                # variable from the EnvironmentFile into the container. This prevents 
                # the API key from appearing in `ps aux` or `systemctl status` logs.
                ExecStart = ''
                    ${pkgs.docker}/bin/docker run --rm \
                    --name openhands-app \
                    --network ${openhandsDockernet} \
                    --cpus="${config.openhands.cpus}" \
                    --memory="${config.openhands.mem}" \
                    --memory-swap="${config.openhands.mem}" \
                    -e LLM_MODEL \
                    -e LLM_API_KEY \
                    -e WORKSPACE_BASE \
                    -e AGENT_SERVER_IMAGE_REPOSITORY=ghcr.io/openhands/agent-server \
                    -e AGENT_SERVER_IMAGE_TAG=1.11.4-python \
                    -e LOG_ALL_EVENTS=true \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v ${config.openhands.home}/state:/.openhands-state \
                    -v ${config.openhands.home}/workspace:/opt/workspace_base \
                    -p 3000:3000 \
                    ${config.openhands.container}
                '';

                ExecStop = "${pkgs.docker}/bin/docker stop openhands-app";

                # Auto-restart on crashes
                Restart = "on-failure";
                RestartSec = "10s";
            };
        };
    };
}