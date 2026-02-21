{ config, pkgs, lib, ... }:
{
    options.transparent-proxy = {
        enable = lib.mkEnableOption "Enable OpenHands autonomous coding service";
        listenIp = lib.mkOption {
            type = lib.types.str;
            default = "172.18.0.1";
        };
        ipCidr = lib.mkOption {
            type = lib.types.str;
            default = "172.18.0.0/16";
        };
        allowedDomains = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
                "example.org"
            ];
        };
    };

    config = lib.mkIf config.transparent-proxy.enable {
        # 1. Squid Proxy (Domain Filtering)
        services.squid = {
            enable = true;
            extraConfig = ''
            # Define the allowed domain
            ${lib.concatMapStringsSep "\n" (domain: "acl allowed_domains dstdomain ${domain}") config.transparent-proxy.allowedDomains}
            
            # Allow traffic to allowed_domains, deny absolutely everything else
            http_access allow allowed_domains
            http_access deny all
            '';
        };

        # 2. Redsocks (Transparent Network Interception)
        systemd.services.openhands-redsocks = {
            description = "OpenHands Isolated Transparent Proxy (Redsocks)";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" "squid.service" ];
            
            serviceConfig = let
                redsocksConf = pkgs.writeText "redsocks.conf" ''
                    base {
                        log_debug = off;
                        log_info = on;
                        daemon = off;
                        redirector = iptables;
                    }
                    redsocks {
                        local_ip = ${config.transparent-proxy.listenIp}; 
                        local_port = 12345;
                        ip = 127.0.0.1;
                        port = 3128;
                        type = http-connect;
                    }
                '';
            in {
                Type = "simple";
                # Run the redsocks binary directly using our custom config file
                ExecStart = "${pkgs.redsocks}/bin/redsocks -c ${redsocksConf}";
                Restart = "on-failure";
                User = "nobody";
            };
        };

        # 3. Iptables (Targeting ONLY the isolated subnet)
        networking.firewall.extraCommands = ''
            # Rule 1: Intercept HTTPS (443) leaving ONLY the 172.18.0.x subnet
            # and redirect it to Redsocks. 
            iptables -t nat -I PREROUTING -s 172.18.0.0/16 -p tcp --dport 443 -j REDIRECT --to-ports 12345

            # Rule 2: Intercept HTTP (80) just in case you ever whitelist an HTTP domain in Squid
            iptables -t nat -I PREROUTING -s 172.18.0.0/16 -p tcp --dport 80 -j REDIRECT --to-ports 12345

            # Rule 3: Hard-drop all other outbound traffic from this specific subnet.
            # Because REDIRECT (above) alters the packet to hit localhost (INPUT chain), 
            # the proxied traffic bypasses this FORWARD/DOCKER-USER drop rule.
            iptables -I DOCKER-USER -s 172.18.0.0/16 ! -d 172.18.0.0/16 -j REJECT
        '';

        networking.firewall.extraStopCommands = ''
            iptables -t nat -D PREROUTING -s 172.18.0.0/16 -p tcp --dport 443 -j REDIRECT --to-ports 12345 || true
            iptables -t nat -D PREROUTING -s 172.18.0.0/16 -p tcp --dport 80 -j REDIRECT --to-ports 12345 || true
            iptables -D DOCKER-USER -s 172.18.0.0/16 ! -d 172.18.0.0/16 -j REJECT || true
        '';

        # 4. Update the OpenHands Systemd Service
        systemd.services.openhands = {
            # Ensure network setup happens before the container starts
            preStart = ''
            mkdir -p /var/lib/openhands/workspace
            mkdir -p /var/lib/openhands/state
            
            # Create the custom isolated network if it doesn't exist
            ${pkgs.docker}/bin/docker network inspect openhands_net >/dev/null 2>&1 || \
            ${pkgs.docker}/bin/docker network create --subnet=172.18.0.0/16 openhands_net
            '';

            serviceConfig = {
            # ... (Keep your existing User, Group, and EnvironmentFile lines here) ...
            
            # Add the --network flag to the docker run command
            ExecStart = ''
                ${pkgs.docker}/bin/docker run --rm \
                --name openhands-app \
                --network openhands_net \
                -e LLM_MODEL \
                -e LLM_API_KEY \
                -e WORKSPACE_BASE \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v /var/lib/openhands/state:/.openhands-state \
                -v /var/lib/openhands/workspace:/opt/workspace_base \
                -p 3000:3000 \
                docker.all-hands.dev/all-hands-ai/openhands:latest
            '';
            };
        };
        };
}