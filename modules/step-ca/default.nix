{ lib, config, ... }:
let
  step-path = "/var/lib/step-ca";
  nixos-path = "/etc/nixos";
in
{
  age.secrets = {
    step-pass = {
      file = ../../encrypt/step-ca/pass.age;
      mode = "0600";
      owner = "step-ca";
      group = "step-ca";
    };
    step-ca = {
      file = ../../encrypt/step-ca/ca.key.age;
      mode = "0600";
      owner = "step-ca";
      group = "step-ca";
    };
  };

  services.step-ca = {
    enable = true;
    openFirewall = false;
    port = 443;
    intermediatePasswordFile = config.age.secrets.step-pass.path;
    address = "0.0.0.0";
    settings = {
      dnsNames = [
        "10.3.10.7"
        "10.3.20.7"
        "danu-02.adrp.xyz"
      ];
      root = "${nixos-path}/certs/derpy.crt";
      crt = "${nixos-path}/certs/derpy-jump.crt";
      key = config.age.secrets.step-ca.path;
      db = {
        type = "badgerV2";
        dataSource = "${step-path}/db";
        badgerFileLoadingMode = "FileIO";
      };
      logger.format = "text";
      authority = {
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "192h";
          defaultTLSCertDuration = "168h";
        };
        provisioners = [
          {
            type = "ACME";
            name = "acme";
            claims = {
              minTLSCertDuration = "5m";
              maxTLSCertDuration = "192h";
              defaultTLSCertDuration = "168h";
            };
          }
          {
            type = "JWK";
            name = "admin";
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoieThlSzFsdnJuV1MtMUlobTlZcFZ3dyJ9.IDNnI0xvNGcM81YE41cZ28k0edmnccmQ3Z72gSwkM33Yvz62-zA1yg.mXiFj4fx08yGClpQ.tZbKIpJzLRVFr1uEYI2fu0W0OOXaf6XajA7krQibMxL4ia4GwmoFX_AuibgYzGsoOIeOpj7I4W5E-c2paLSPfBeUrmZOHWEuXFjVn9x4teuultPqyQl8yP8V9vJM6dzwCYsjlQGzPSWBZb9gB-6BQobwvfRcWUNQHajy42hhNYrLQrZiHLa5Mw2G0NNEuvAFpMoQcaZg-cYm4GHUMlzfzAmYIQuSfpfSgEk8Xn4EN36w1vgxUC-DiOxlhZQ9Qj-1CtNugo9ddyZihpTExuopXUd7kV4leKy6hJTsl4eNUJeyf1kYxpiSyLNs5UGwAxOiMTNu5N0zSM0Ll8Ugktg.2Rr2TUrQSiTF2Lt0IFK7wQ";
            key = {
              use = "sig";
              kty = "EC";
              crv = "P-256";
              alg = "ES256";
              kid = "enYWyUm4LAkoKTPTxeKuFwGs6_o9sjfhAMNkmM-evI0";
              x = "QpitIT9M24Q8NO3we2afx4A1VjCZ5W5qooYvdNltK1s";
              y = "6p6uXqvkPXFW-6SFTy-T1oIcgSoMfpCzuMflcl3Gllg";
            };
            claims = {
              minTLSCertDuration = "192h";
              maxTLSCertDuration = "8760h";
              defaultTLSCertDuration = "730h";
            };
          }
          {
            type = "JWK";
            name = "admin-mtls";
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoieThlSzFsdnJuV1MtMUlobTlZcFZ3dyJ9.IDNnI0xvNGcM81YE41cZ28k0edmnccmQ3Z72gSwkM33Yvz62-zA1yg.mXiFj4fx08yGClpQ.tZbKIpJzLRVFr1uEYI2fu0W0OOXaf6XajA7krQibMxL4ia4GwmoFX_AuibgYzGsoOIeOpj7I4W5E-c2paLSPfBeUrmZOHWEuXFjVn9x4teuultPqyQl8yP8V9vJM6dzwCYsjlQGzPSWBZb9gB-6BQobwvfRcWUNQHajy42hhNYrLQrZiHLa5Mw2G0NNEuvAFpMoQcaZg-cYm4GHUMlzfzAmYIQuSfpfSgEk8Xn4EN36w1vgxUC-DiOxlhZQ9Qj-1CtNugo9ddyZihpTExuopXUd7kV4leKy6hJTsl4eNUJeyf1kYxpiSyLNs5UGwAxOiMTNu5N0zSM0Ll8Ugktg.2Rr2TUrQSiTF2Lt0IFK7wQ";
            key = {
              use = "sig";
              kty = "EC";
              crv = "P-256";
              alg = "ES256";
              kid = "enYWyUm4LAkoKTPTxeKuFwGs6_o9sjfhAMNkmM-evI0";
              x = "QpitIT9M24Q8NO3we2afx4A1VjCZ5W5qooYvdNltK1s";
              y = "6p6uXqvkPXFW-6SFTy-T1oIcgSoMfpCzuMflcl3Gllg";
            };
            claims = {
              minTLSCertDuration = "192h";
              maxTLSCertDuration = "8760h";
              defaultTLSCertDuration = "730h";
            };
            options.x509.templateData = {
              subject = {
                organizationalUnit = "{{ toJson .OrganizationalUnit }}";
                commonName = "{{ toJson .Subject.CommonName }}";
              };
              sans = "{{ toJson .SANs }}";
              keyUsage = [ "digitalSignature" ];
              extKeyUsage = [
                "serverAuth"
                "clientAuth"
              ];
            };
          }
          {
            type = "JWK";
            name = "kubernetes";
            encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoid0FxUjJuZW5LOHBXQzZZcm5UbkxyZyJ9.Lyre3Yl7ro2rlHYUxQBM0tXj5a4z36yNKUUUmYf00_M-GLc8RX__3A.0J1ZkNRm95gOadAi.nvHBWm_jwFBTxn_EowQ1DvRO2YWBgEC_WQSjjfKUqEohuRKhTmLAJ0VYnlCma5lUTl91N7BLGljKnOnAEXOG-Jm7nLwWM-urpTIe_F1AyT1QKvStmgCiokdBPyDSi-ghZRS-LpuwkT81vRUxJY7C_1OCqFzhw6u6T6-dXKeTK3FwRdEcUmcXoQinaQTDsCjKreb6BmyBLlVjx6xBoBdEgJxcN6LqWChXJRPJXD8U5I9occt_v-HfPWK7gmVOLmrDtCnG45evsqyst37HR-EelKoVU35VlHEf99qgeKEAkJyPfXzyKzSkk1bIHloVEJ0MKUR5_5aDln8ok-0BoAs.OriFcB2dUSk-_sk9FPs7Iw";
            key = {
              use = "sig";
              kty = "EC";
              kid = "bVG_kusWz2BVahg5ZS7p8j10U6pEHRma5QuHQF9PHwU";
              crv = "P-256";
              alg = "ES256";
              x = "K7GVIi433St3nS7ED002bu8RF0k36RtKOZWrOXgJX9M";
              y = "LOYTwTgach14e4kbSIkrUQe8R0j-JgnsQwu6k0RPJoY";
            };
            claims = {
              minTLSCertDuration = "5m";
              maxTLSCertDuration = "192h";
              defaultTLSCertDuration = "168h";
            };
          }
        ];
      };
    };
  };

  users.users.step-ca = {
    extraGroups = [ "secrets" ];
    group = "step-ca";
    isSystemUser = true;
  };
  users.groups.step-ca = { };

  systemd = {
    tmpfiles.rules = [
      "d ${step-path} 700 step-ca step-ca"
      "Z ${step-path} 700 step-ca step-ca"
    ];
    services."step-ca" = {
      serviceConfig = {
        WorkingDirectory = lib.mkForce "${step-path}";
        Environment = lib.mkForce "Home=${step-path}";
        User = "step-ca";
        Group = "step-ca";
        DynamicUser = lib.mkForce false;
      };
    };
  };
}
