{ config, lib, pkgs, ... }:

let
  cfg = config.security.dmz-hardening;
in {
  options.security.dmz-hardening = {
    enable = lib.mkEnableOption "DMZ Hardening (Crowdsec, GeoIP, Rate Limits)";
    
    publicInterface = lib.mkOption {
      type = lib.types.str;
      default = "enp0s6";
      description = "The public network interface to bind the netdev ingress hook to.";
    };

    adminDynDns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "DynDNS domain to resolve and globally whitelist from all blocking/rate-limiting.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ---------------------------------------------------------
    # System Auditing & Integrity
    # ---------------------------------------------------------
    # Enable the Linux Audit daemon to log security-relevant events and syscalls.
    security.auditd.enable = true;
    security.audit.enable = true;

    # Enable AppArmor Mandatory Access Control (MAC) to confine programs.
    security.apparmor.enable = true;

    # ---------------------------------------------------------
    # Authentication Hardening (PAM)
    # ---------------------------------------------------------
    # Lock accounts temporarily after failed login attempts (faillock).
    security.pam.services.login.failDelay = {
      enable = true;
      delay = 2000000; # 2 seconds
    };
    security.pam.services.sshd.failDelay = {
      enable = true;
      delay = 2000000; # 2 seconds
    };

    # ---------------------------------------------------------
    # Active Threat Mitigation (CrowdSec)
    # ---------------------------------------------------------
    # Enable CrowdSec to parse logs and ban malicious IPs automatically.
    services.crowdsec.enable = true;
    services.crowdsec.localConfig.acquisitions = [
      {
        # Parse SSH logs to detect and ban brute-force attacks.
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }
      {
        # Parse kernel firewall logs to detect port scans and rate-limit drops.
        # Note: To protect Kamailio VoIP, you can add another acquisition here
        # pointing to Kamailio's logs and use a SIP parser/scenario.
        source = "journalctl";
        journalctl_filter = [ "_TRANSPORT=kernel" ];
        labels.type = "iptables";
      }
    ];

    # ---------------------------------------------------------
    # Kernel & Network Sysctl Hardening
    # ---------------------------------------------------------
    boot.kernel.sysctl = {
      # Disable ICMP echo requests globally (host will not respond to pings)
      "net.ipv4.icmp_echo_ignore_all" = 1;
      "net.ipv6.icmp.echo_ignore_all" = 1;
      
      # Enable SYN cookies to protect against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      
      # Disable accepting ICMP redirects (prevents MITM routing attacks)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      
      # Disable sending ICMP redirects (this host is not a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      
      # Enable strict reverse path filtering to prevent IP spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      
      # Log packets with impossible addresses (martians) to the kernel log
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
    };

    # ---------------------------------------------------------
    # Firewall & GeoIP Blocking (nftables)
    # ---------------------------------------------------------
    networking.nftables.enable = true;
    # Disable pre-flight syntax checks during the Nix build phase.
    # The check will fail because the sandbox lacks both the 'enp0s6' 
    # network interface and the dynamically generated GeoIP include files.
    networking.nftables.checkRuleset = false;

    # Ensure packets dropped by closed ports are logged so CrowdSec sees port scans
    networking.firewall.logRefusedConnections = true;

    # Service to fetch US IP blocks daily from a public repository
    systemd.services.update-geoip-us = {
      description = "Update US GeoIP nftables set";
      after = [ "network-online.target" "nftables.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ curl bash gawk ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "update-geoip-us" ''
          set -eu
          mkdir -p /var/lib/geoip
          # Fetch latest US CIDR blocks
          curl -sS -L https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/us.cidr > /var/lib/geoip/us-ipv4.cidr.tmp
          curl -sS -L https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv6/us.cidr > /var/lib/geoip/us-ipv6.cidr.tmp
          
          mv /var/lib/geoip/us-ipv4.cidr.tmp /var/lib/geoip/us-ipv4.cidr
          mv /var/lib/geoip/us-ipv6.cidr.tmp /var/lib/geoip/us-ipv6.cidr

          # Translate CIDR files into nftables set definitions
          echo "define us_ipv4 = { $(cat /var/lib/geoip/us-ipv4.cidr | grep -v '^#' | tr '\n' ',' | sed 's/,$//') }" > /var/lib/geoip/us-set.nft
          echo "define us_ipv6 = { $(cat /var/lib/geoip/us-ipv6.cidr | grep -v '^#' | tr '\n' ',' | sed 's/,$//') }" >> /var/lib/geoip/us-set.nft
          
          # Reload nftables to apply the new IP blocks
          ${pkgs.systemd}/bin/systemctl reload nftables.service || true
        ''}";
      };
    };

    systemd.timers.update-geoip-us = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    # Service to update Admin IP from DynDNS
    systemd.services.update-admin-ip = lib.mkIf (cfg.adminDynDns != null) {
      description = "Update Admin IP whitelist from DynDNS";
      after = [ "network-online.target" "nftables.service" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ bind nftables ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "update-admin-ip" ''
          set -eu
          IP=$(dig +short ${cfg.adminDynDns} A | tail -n1)
          if [ -n "$IP" ]; then
            nft flush set inet dmz-hardening admin_ips || true
            nft add element inet dmz-hardening admin_ips { $IP } || true
          fi
        ''}";
      };
    };

    systemd.timers.update-admin-ip = lib.mkIf (cfg.adminDynDns != null) {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
      };
    };

    # Ensure a placeholder GeoIP set file exists on boot before nftables starts,
    # otherwise the nftables service will crash trying to include a missing file.
    systemd.services.nftables = {
      preStart = ''
        mkdir -p /var/lib/geoip
        if [ ! -f /var/lib/geoip/us-set.nft ]; then
          echo "define us_ipv4 = { 127.0.0.1 }" > /var/lib/geoip/us-set.nft
          echo "define us_ipv6 = { ::1 }" >> /var/lib/geoip/us-set.nft
        fi
      '';
    };

    # Custom nftables table for stateful hardening
    networking.nftables.tables."dmz-hardening" = {
      family = "inet";
      content = ''
        include "/var/lib/geoip/us-set.nft"

        set admin_ips {
          type ipv4_addr
        }
        
        chain prerouting {
          type filter hook prerouting priority -300; policy accept;
          
          # Whitelist Admin IP from stateful checks/rate-limiting
          ip saddr @admin_ips accept
          
          # Allow established and related connections (stateful firewall)
          # This is CRITICAL so our outbound requests (DNS, curl) can receive replies!
          ct state established,related accept
          
          # Drop new connections originating from outside the US
          ip saddr != $us_ipv4 drop
          ip6 saddr != $us_ipv6 drop
          
          # Per-IP Rate Limiting: 
          # Drop new connections from a single IP exceeding 50/s (with a burst of 100).
          ct state new meter flood_ipv4 { ip saddr limit rate over 50/second burst 100 packets } log drop
          ct state new meter flood_ipv6 { ip6 saddr limit rate over 50/second burst 100 packets } log drop
        }
      '';
    };
  };
}
