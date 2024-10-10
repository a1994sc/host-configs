{
  config,
  pkgs,
  lib,
  outputs,
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

  environment.systemPackages = with pkgs; [ build.matchbox ];

  nixpkgs.overlays = [ outputs.overlays.build-packages ];

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

  sops.validateSopsFiles = false;
  sops.secrets = {
    ca-crt = {
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
      sopsFile = ../../secrets/dhcp/matchbox.yml;
      mode = "0600";
    };
    tls-crt = {
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
      sopsFile = ../../secrets/dhcp/matchbox.yml;
      mode = "0600";
    };
    tls-key = {
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
      sopsFile = ../../secrets/dhcp/matchbox.yml;
      mode = "0600";
    };
    env = {
      owner = "${config.users.users.matchbox.name}";
      group = "${config.users.groups.matchbox.name}";
      sopsFile = ../../secrets/dhcp/matchbox.yml;
      mode = "0600";
    };
  };

  system.activationScripts = {
    makeVaultWardenDir = lib.stringAfter [ "var" ] ''
      ${pkgs.coreutils}/bin/mkdir -p ${tftp-path}
      if [[ ! -f ${tftp-path}/ipxe.efi ]]; then
        ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/ipxe.efi to ${tftp-path}/ipxe.efi"
        ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/ipxe.efi -o ${tftp-path}/ipxe.efi
      fi
      if [[ ! -f ${tftp-path}/snponly.efi ]]; then
        ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/snponly.efi to ${tftp-path}/snponly.efi"
        ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/snponly.efi -o ${tftp-path}/snponly.efi
      fi
      if [[ ! -f ${tftp-path}/ipxe-arm64.efi ]]; then
        ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/arm64-efi/ipxe.efi to ${tftp-path}/ipxe-arm64.efi"
        ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/arm64-efi/ipxe.efi -o ${tftp-path}/ipxe-arm64.efi
      fi
      if [[ ! -f ${tftp-path}/snponly-arm64.efi ]]; then
        ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/arm64-efi/snponly.efi to ${tftp-path}/snponly-arm64.efi"
        ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/arm64-efi/snponly.efi -o ${tftp-path}/snponly-arm64.efi
      fi
      if [[ ! -f ${tftp-path}/undionly.kpxe ]]; then
        ${pkgs.coreutils}/bin/echo "Download https://boot.ipxe.org/undionly.kpxe to ${tftp-path}/undionly.kpxe"
        ${pkgs.curl}/bin/curl -# https://boot.ipxe.org/undionly.kpxe -o ${tftp-path}/undionly.kpxe
        ${pkgs.coreutils}/bin/cp ${tftp-path}/undionly.kpxe ${tftp-path}/undionly.kpxe.0
      fi
    '';
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
          "tag:#ipxe, X86PC     , \"Chain to iPXE\"           , undionly.kpxe                  ,10.3.20.6"
          "tag:ipxe , X86PC     , \"iPXE\"                    , http://10.3.20.6:8080/boot.ipxe"
          "tag:#ipxe, X86-64_EFI, \"Chain to iPXE UEFI\"      , snponly.efi                    ,10.3.20.6"
          "tag:ipxe , X86-64_EFI, \"iPXE UEFI\"               , http://10.3.20.6:8080/boot.ipxe"
          "tag:#ipxe, ARM32_EFI , \"Chain to ARM32 iPXE UEFI\", snponly-arm64.efi              ,10.3.20.6"
          "tag:ipxe , ARM32_EFI , \"iPXE UEFI\"               , http://10.3.20.6:8080/boot.ipxe"
          "tag:#ipxe, ARM64_EFI , \"Chain to ARM64 iPXE UEFI\", snponly-arm64.efi              ,10.3.20.6"
          "tag:ipxe , ARM64_EFI , \"iPXE UEFI\"               , http://10.3.20.6:8080/boot.ipxe"
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
      MATCHBOX_DATA_PATH = "${data-path}";
      MATCHBOX_ASSETS_PATH = "${data-path}/assets";
      MATCHBOX_CA_FILE = config.sops.secrets.ca-crt.path;
      MATCHBOX_CERT_FILE = config.sops.secrets.tls-crt.path;
      MATCHBOX_KEY_FILE = config.sops.secrets.tls-key.path;
      MATCHBOX_PASSPHRASE = builtins.readFile config.sops.secrets.env.path;
    };
    serviceConfig = {
      User = "${user}";
      Group = "${user}";
      ExecStart = "${pkgs.build.matchbox}/bin/matchbox";
      ProtectHome = "yes";
      ProtectSystem = "full";
    };
  };
}
