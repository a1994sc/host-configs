{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkConnection
    mkSwitch
    mkDevice
    ;
in
{
  networks = {
    omada = {
      name = "Omada Machines";
      cidrv4 = "10.3.0.1/24";
    };
    core = {
      name = "Core";
      cidrv4 = "10.3.10.0/24";
    };
    wee-fee = {
      name = "Untrusted";
      cidrv4 = "10.3.15.0/24";
    };
    machine = {
      name = "Machine";
      cidrv4 = "10.3.20.0/23";
    };
    untrusted = {
      name = "Untrusted";
      cidrv4 = "10.3.25.0/24";
    };
    personal = {
      name = "Personal";
      cidrv4 = "10.3.30.0/24";
    };
    work = {
      name = "Work";
      cidrv4 = "10.3.105.0/24";
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
      info = "TP-link ER605";
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
        eth1 = mkConnection "switch-poe" "eth0";
      };
    };
    controller = mkDevice "controller" {
      info = "TP-link OC200";
      interfaceGroups = [
        [ "eth1" ]
        [ "eth2" ]
      ];
      interfaces = {
        eth1.network = "omada";
      };
    };
    wee-fee = mkDevice "wi-fi" {
      info = "TP-link EAP615-Wall";
      interfaceGroups = [
        [ "eth1" ]
      ];
    };
    switch-poe = mkSwitch "Switch-POE" {
      info = ''
        TP-link SG2210P
        Ports: 8 Gigabit, 2 SFP
      '';
      interfaceGroups = (builtins.genList (x: [ ("eth" + builtins.toString x) ]) 8) ++ [
        [ "sfp1" ]
        [ "sfp2" ]
      ];
      connections = {
        eth1 = mkConnection "controller" "eth1";
        eth2 = mkConnection "router" "eth1";
        eth7 = mkConnection "switch-back" "eth1";
        eth8 = mkConnection "wee-fee" "eth1";
      };
      interfaces = {
        eth1.network = "omada";
        eth2.network = "trunk";
        eth3.network = "disconnected";
        eth4.network = "disconnected";
        eth5.network = "disconnected";
        eth6.network = "disconnected";
        eth7.network = "trunk";
        eth8.network = "wee-fee";
        sfp1.network = "disconnected";
        sfp2.network = "disconnected";
      };
    };
    switch-back = mkSwitch "Switch-back" {
      info = "TP-link SG3428";
      interfaceGroups = (builtins.genList (x: [ ("eth" + builtins.toString x) ]) 24) ++ [
        [ "sfp1" ]
        [ "sfp2" ]
        [ "sfp3" ]
        [ "sfp4" ]
      ];
      connections = {
      };
      interfaces = {
      };
    };

  };
}
