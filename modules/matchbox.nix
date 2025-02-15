{
  config,
  pkgs,
  outputs,
  system,
  lib,
  ...
}:
let
  cfg = config.ascii.system.matchbox;
in
{
  options.ascii.system.matchbox = {
    enable = lib.mkEnableOption "nix";
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/matchbox";
    };
    tftpDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tftp";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "matchbox";
    };
    talosVersion = lib.mkOption {
      type = lib.types.str;
    };
    age = {
      env = lib.mkOption {
        type = lib.types.path;
      };
      ca = lib.mkOption {
        type = lib.types.path;
      };
      crt = lib.mkOption {
        type = lib.types.path;
      };
      key = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ matchbox-server ];

    users = {
      groups.${cfg.user} = { };
      users.${cfg.user} = {
        isNormalUser = false;
        uid = 993;
        group = cfg.user;
        home = cfg.tftpDir;
        createHome = true;
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = config.users.users.custodian.openssh.authorizedKeys.keys;
      };
    };

    age.secrets = {
      ca-crt = {
        file = cfg.age.ca;
        mode = "0600";
        owner = cfg.user;
        group = cfg.user;
      };
      tls-crt = {
        file = cfg.age.crt;
        mode = "0600";
        owner = cfg.user;
        group = cfg.user;
      };
      tls-key = {
        file = cfg.age.key;
        mode = "0600";
        owner = cfg.user;
        group = cfg.user;
      };
      env = {
        file = cfg.age.env;
        mode = "0600";
        owner = cfg.user;
        group = cfg.user;
      };
    };

    system.activationScripts = {
      ipxe = {
        text = ''
          ${pkgs.coreutils}/bin/mkdir -p ${cfg.tftpDir}
          if [[ ! -f ${cfg.tftpDir}/ipxe.efi ]]; then
            ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/ipxe.efi to ${cfg.tftpDir}/ipxe.efi"
            ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/ipxe.efi -o ${cfg.tftpDir}/ipxe.efi
          fi
          if [[ ! -f ${cfg.tftpDir}/snponly.efi ]]; then
            ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/snponly.efi to ${cfg.tftpDir}/snponly.efi"
            ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/snponly.efi -o ${cfg.tftpDir}/snponly.efi
          fi
          if [[ ! -f ${cfg.tftpDir}/ipxe-arm64.efi ]]; then
            ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/arm64-efi/ipxe.efi to ${cfg.tftpDir}/ipxe-arm64.efi"
            ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/arm64-efi/ipxe.efi -o ${cfg.tftpDir}/ipxe-arm64.efi
          fi
          if [[ ! -f ${cfg.tftpDir}/snponly-arm64.efi ]]; then
            ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/arm64-efi/snponly.efi to ${cfg.tftpDir}/snponly-arm64.efi"
            ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/arm64-efi/snponly.efi -o ${cfg.tftpDir}/snponly-arm64.efi
          fi
          if [[ ! -f ${cfg.tftpDir}/undionly.kpxe ]]; then
            ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/undionly.kpxe to ${cfg.tftpDir}/undionly.kpxe"
            ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/undionly.kpxe -o ${cfg.tftpDir}/undionly.kpxe
            ${pkgs.coreutils}/bin/cp ${cfg.tftpDir}/undionly.kpxe ${cfg.tftpDir}/undionly.kpxe.0
          fi
        '';
      };
      talos =
        let
          initramfs-amd64 = outputs.packages.${system}."talos-${cfg.talosVersion}-initramfs-amd64";
          initramfs-arm64 = outputs.packages.${system}."talos-${cfg.talosVersion}-initramfs-arm64";
          vmlinuz-amd64 = outputs.packages.${system}."talos-${cfg.talosVersion}-vmlinuz-amd64";
          vmlinuz-arm64 = outputs.packages.${system}."talos-${cfg.talosVersion}-vmlinuz-arm64";
        in
        {
          text = ''
            ${pkgs.coreutils}/bin/mkdir -p ${cfg.dataDir}/assets/
            cp -rf ${initramfs-amd64}/initramfs-amd64.xz ${cfg.dataDir}/assets/initramfs-amd64.xz
            cp -rf ${initramfs-arm64}/initramfs-arm64.xz ${cfg.dataDir}/assets/initramfs-arm64.xz
            cp -rf ${vmlinuz-amd64}/vmlinuz-amd64 ${cfg.dataDir}/assets/vmlinuz-amd64
            cp -rf ${vmlinuz-arm64}/vmlinuz-arm64 ${cfg.dataDir}/assets/vmlinuz-arm64

            ${pkgs.coreutils}/bin/chown ${config.users.users.${cfg.user}.name}:${
              config.users.groups.${cfg.user}.name
            } -R ${cfg.dataDir}
          '';
        };
    };

    services = {
      atftpd = {
        enable = true;
        root = "${cfg.tftpDir}";
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
          interface = "vlan20";
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
        MATCHBOX_DATA_PATH = "${cfg.dataDir}";
        MATCHBOX_ASSETS_PATH = "${cfg.dataDir}/assets";
        MATCHBOX_CA_FILE = config.age.secrets.ca-crt.path;
        MATCHBOX_CERT_FILE = config.age.secrets.tls-crt.path;
        MATCHBOX_KEY_FILE = config.age.secrets.tls-key.path;
        MATCHBOX_PASSPHRASE = builtins.readFile config.age.secrets.env.path;
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.user;
        ExecStart = "${pkgs.matchbox-server}/bin/matchbox";
        ProtectHome = "yes";
        ProtectSystem = "full";
      };
    };
  };
}
