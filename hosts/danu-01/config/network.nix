{ config, ... }:
{
  # one NIC carries both L2s; answer ARP only for the address on that link
  boot.kernel.sysctl = {
    "net.ipv4.conf.default.arp_filter" = 1;
    "net.ipv4.conf.all.arp_filter" = 1;
  };

  networking = {
    hostName = "danu-01";
    domain = "adrp.xyz";
    search = [ "adrp.xyz" ];
    useNetworkd = true;
    useDHCP = false;
    wireless.enable = false;
    # the host resolves upstream directly, so a blocky outage can't block a rebuild
    nameservers = [
      "1.1.1.2"
      "1.0.0.2"
    ];
    firewall.allowedUDPPorts = [ 53 ];
    firewall.allowedTCPPorts = [
      22
      53
    ];
  };

  systemd.network = {
    enable = true;
    netdevs."20-vlan20" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan20";
      };
      vlanConfig.Id = 20;
    };
    networks = {
      "00-core" = {
        matchConfig.Name = "en*";
        address = [ "10.3.10.5/24" ];
        routes = [ { Gateway = "10.3.10.1"; } ];
        vlan = [ "vlan20" ];
      };
      "40-vlan20" = {
        matchConfig.Name = "vlan20";
        address = [ "10.3.20.5/23" ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      LoginGraceTime = 0;
    };
  };

  services.comin = {
    enable = true;
    hostname = config.networking.hostName;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/a1994sc/host-configs.git";
        branches.main.name = "main";
      }
    ];
  };
}
