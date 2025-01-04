{
  config,
  pkgs,
  outputs,
  system,
  ...
}:
let
  path = "/etc/nixos";
  user = "matchbox";
  data-path = "/var/lib/matchbox";
  tftp-path = "/var/lib/tftp";
in
{

  imports = [ ./scripts.nix ];

  environment.systemPackages = with pkgs; [ matchbox-server ];

  users = {
    groups.matchbox = { };
    users.matchbox = {
      isNormalUser = false;
      uid = 993;
      group = "${user}";
      home = "${data-path}";
      createHome = true;
      openssh.authorizedKeys.keys = config.users.users.custodian.openssh.authorizedKeys.keys;
    };
  };

  age.secrets = {
    ca-crt = {
      file = ../../encrypt/matchbox/ca.crt.age;
      mode = "0600";
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
    };
    tls-crt = {
      file = ../../encrypt/matchbox/tls.crt.age;
      mode = "0600";
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
    };
    tls-key = {
      file = ../../encrypt/matchbox/tls.key.age;
      mode = "0600";
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
    };
    env = {
      file = ../../encrypt/matchbox/env.age;
      mode = "0600";
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
    };
  };

  system.activationScripts = {
    ipxe =
      let
        inherit (outputs.packages.${system}) ipxe;
      in
      {
        text = ''
          ${pkgs.coreutils}/bin/mkdir -p ${tftp-path}
          cp -rf ${ipxe}/ipxe.efi ${tftp-path}/ipxe.efi
          cp -rf ${ipxe}/undionly.kpxe ${tftp-path}/undionly.kpxe
          cp -rf ${ipxe}/undionly.kpxe ${tftp-path}/undionly.kpxe.0
          cp -rf ${ipxe}/snponly.efi ${tftp-path}/snponly.efi
        '';
      };
    talos =
      let
        talos-version = "1-9";
        initramfs-amd64 = outputs.packages.${system}."talos-${talos-version}-initramfs-amd64";
        initramfs-arm64 = outputs.packages.${system}."talos-${talos-version}-initramfs-arm64";
        vmlinuz-amd64 = outputs.packages.${system}."talos-${talos-version}-vmlinuz-amd64";
        vmlinuz-arm64 = outputs.packages.${system}."talos-${talos-version}-vmlinuz-arm64";
      in
      {
        text = ''
          ${pkgs.coreutils}/bin/mkdir -p ${data-path}/assets/
          cp -rf ${initramfs-amd64}/initramfs-amd64.xz ${data-path}/assets/initramfs-amd64.xz
          cp -rf ${initramfs-arm64}/initramfs-arm64.xz ${data-path}/assets/initramfs-arm64.xz
          cp -rf ${initramfs-arm64}/vmlinuz-amd64 ${data-path}/assets/vmlinuz-amd64
          cp -rf ${initramfs-arm64}/vmlinuz-arm64 ${data-path}/assets/vmlinuz-arm64

          ${pkgs.coreutils}/bin/chown ${config.users.users.matchbox.name}:${config.users.groups.matchbox.name} -R ${data-path}
        '';
      };
  };

  services = {
    atftpd = {
      enable = true;
      root = "${tftp-path}";
    };
    dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        dhcp-range = "10.3.20.1,proxy,255.255.254.0";
        dhcp-userclass = "set:ipxe,iPXE";
        pxe-service = [
          "tag:#ipxe, X86PC     , \"Chain to iPXE\"           , undionly.kpxe                  ,10.3.20.7"
          "tag:ipxe , X86PC     , \"iPXE\"                    , http://10.3.20.7:8080/boot.ipxe"
          "tag:#ipxe, X86-64_EFI, \"Chain to iPXE UEFI\"      , snponly.efi                    ,10.3.20.7"
          "tag:ipxe , X86-64_EFI, \"iPXE UEFI\"               , http://10.3.20.7:8080/boot.ipxe"
        ];
        port = 0;
        log-queries = true;
        dhcp-no-override = true;
        interface = "vlan20@eth0";
        dhcp-option = [ "option:domain-search,adrp.xyz" ];
      };
    };
  };

  systemd.services.matchbox = {
    description = "Matchbox Server";
    documentation = [ "https://github.com/poseidon/matchbox" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      MATCHBOX_ADDRESS = "0.0.0.0:8080";
      MATCHBOX_RPC_ADDRESS = "0.0.0.0:8443";
      MATCHBOX_DATA_PATH = "${data-path}";
      MATCHBOX_ASSETS_PATH = "${data-path}/assets";
      MATCHBOX_CA_FILE = config.age.secrets.ca-crt.path;
      MATCHBOX_CERT_FILE = config.age.secrets.tls-crt.path;
      MATCHBOX_KEY_FILE = config.age.secrets.tls-key.path;
      MATCHBOX_PASSPHRASE = builtins.readFile config.age.secrets.env.path;
    };
    serviceConfig = {
      User = "${user}";
      Group = "${user}";
      ExecStart = "${pkgs.matchbox-server}/bin/matchbox";
      ProtectHome = "yes";
      ProtectSystem = "full";
    };
  };
}
