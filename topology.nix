{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkConnection
    mkSwitch
    ;
in
{
  networks = {
    core = {
      name = "Core";
      cidrv4 = "10.3.10.0/24";
    };
    machine = {
      name = "Machine";
      cidrv4 = "10.3.20.0/23";
    };
    trunk.name = "Trunk";
    disconnected.name = "Disconnected";
    wan = {
      name = "Internet";
      cidrv4 = "0.0.0.0/0";
    };
  };
  nodes = {
    internet = mkInternet { connections = mkConnection "router" "wan0"; };
    router = mkRouter "omada-router" {
      interfaceGroups = [
        [ "eth1" ]
        [ "eth2" ]
        [ "eth3" ]
        [ "eth4" ]
        [ "wan0" ]
      ];
      interfaces = {
        wan0.network = "wan";
        eth1.network = "trunk";
        eth2.network = "disconnected";
        eth3.network = "disconnected";
        eth4.network = "disconnected";
      };
      connections = {
        eth1 = mkConnection "switch" "eth0";
      };
    };
    switch = mkSwitch "Main Switch" {
      info = "D-Link DGS-1016D";
      interfaceGroups = [
        [ "eth0" ]
        [ "eth1" ]
        [ "eth2" ]
        [ "eth3" ]
        [ "eth4" ]
        [ "eth5" ]
      ];
      connections = {
        eth1 = mkConnection "dns1" "eth0";
        eth2 = mkConnection "dns2" "eth0";
        eth3 = mkConnection "dns1" "vlan20";
        eth4 = mkConnection "dns2" "vlan20";
      };
      interfaces = {
        eth0.network = "trunk";
        eth1.network = "core";
        eth2.network = "core";
        eth3.network = "machine";
        eth4.network = "machine";
        eth5.network = "disconnected";
      };
    };
  };
}
