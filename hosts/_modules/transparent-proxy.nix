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
        dockernetName = lib.mkOption {
            type = lib.types.str;
            default = "openhands_net";
        };
    };

    config = lib.mkIf config.transparent-proxy.enable {
        # 1. Squid Proxy (Domain Filtering)
        services.squid = {
            enable = true;
            extraConfig = ''
            dns_v4_first on
            dns_nameservers 1.1.1.3 208.67.222.123

            http_port 127.0.0.1:3128
            http_port 172.18.0.1:3128

            cache deny all

            # Define the allowed domain
            ${lib.concatMapStringsSep "\n" (domain: "acl allowed_domains dstdomain ${domain}") config.transparent-proxy.allowedDomains}
            
            # Allow traffic to allowed_domains, deny absolutely everything else
            http_access allow allowed_domains
            http_access deny all
            '';
        };

        # TODO make optional
        environment.systemPackages = with pkgs; [
            docker
        ];

        users.groups.svc-redsocks = {};
        users.users.svc-redsocks = {
            isSystemUser = true;
            group = "svc-redsocks";
            extraGroups = [ "docker" ]; # Required for OpenHands to spin up sandboxes
        };

        # 2. Redsocks (Transparent Network Interception)
        systemd.services.my-redsocks = {
            description = "Isolated Transparent Proxy (Redsocks)";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" "squid.service" "docker.socket" "docker.service" ];
            requires = [ "docker.socket" "docker.service" ];

            preStart = ''
                # Create the custom isolated network if it doesn't exist
                ${pkgs.docker}/bin/docker network inspect ${config.transparent-proxy.dockernetName} >/dev/null 2>&1 || \
                ${pkgs.docker}/bin/docker network create --subnet=${config.transparent-proxy.ipCidr} ${config.transparent-proxy.dockernetName}
            '';
            
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
                User = "svc-redsocks";
            };
        };

        networking.firewall.allowedTCPPorts = [ 12345 3128 ];

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

    };
}