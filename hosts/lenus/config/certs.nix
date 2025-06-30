{
  pkgs,
  lib,
  config,
  ...
}:
let
  cacertPackage = pkgs.cacert.override {
    extraCertificateStrings = config.security.pki.certificates;
  };
  caBundle = "${cacertPackage}/etc/ssl/certs/ca-bundle.crt";
in
{
  environment.etc = {
    "ssl/certs/ca-certificates.crt".source = lib.mkForce caBundle;
    "ssl/certs/ca-bundle.crt".source = lib.mkForce caBundle;
    "pki/tls/certs/ca-bundle.crt".source = lib.mkForce caBundle;
    "ssl/trust-source".source = lib.mkForce "${cacertPackage.p11kit}/etc/ssl/trust-source";
  };
  environment.variables.NIX_SSL_CERT_FILE = lib.mkForce caBundle;
  security.pki.certificates = [
    ''
      Derpy CA
      =========
      -----BEGIN CERTIFICATE-----
      MIIBdDCCARqgAwIBAgIRANkYt8S37DW7KItbxVZr9OUwCgYIKoZIzj0EAwIwGDEW
      MBQGA1UEAxMNRGVycHkgUm9vdCBDQTAeFw0yMDEyMzEwMDI1NTNaFw0zMDEyMzEw
      MDI1NTNaMBgxFjAUBgNVBAMTDURlcnB5IFJvb3QgQ0EwWTATBgcqhkjOPQIBBggq
      hkjOPQMBBwNCAATOFoME0It/e323PaeOgrrQZGUGbz3AovjJBBDLAkwld057duoq
      2ppzrcNQYm3/KfFJrGZUbel0PHpIqh4ufFJWo0UwQzAOBgNVHQ8BAf8EBAMCAQYw
      EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUSCs2bRDtMPz4sfHi3sUfJLw5
      nVgwCgYIKoZIzj0EAwIDSAAwRQIhALmYLFGo9FUAGP6wY8vj1Q5wRXW6n6xV/S6T
      RG/LtMsYAiBwzyJT5Ht+D/KnxHCqhDTxb/kQQL41IyEcswrIdDF4wA==
      -----END CERTIFICATE-----
    ''
    ''
      Derpy Jump CA
      =========
      -----BEGIN CERTIFICATE-----
      MIIBlzCCATygAwIBAgIRALtu+fHFHV0lpjOrtu8Tg9wwCgYIKoZIzj0EAwIwGDEW
      MBQGA1UEAxMNRGVycHkgUm9vdCBDQTAeFw0yMjEyMTMwMDEzMzlaFw0zMjEyMTAw
      MDEzMzlaMBkxFzAVBgNVBAMTDkp1bXAtSG9zdCBJbnQuMFkwEwYHKoZIzj0CAQYI
      KoZIzj0DAQcDQgAEq+fR65pLjiLGezo0jqp9fIY1Vlsn9MEmtWA7Zlujw1xQ6+gf
      NNWOuhIcpypQQzaEriQj5PiW0u/WZ9YikhNCtaNmMGQwDgYDVR0PAQH/BAQDAgEG
      MBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFGjlH5UDDQZmr5ATKPoNDoCb
      E3DXMB8GA1UdIwQYMBaAFEgrNm0Q7TD8+LHx4t7FHyS8OZ1YMAoGCCqGSM49BAMC
      A0kAMEYCIQDyi9rqEpzzfS8JCmN/DI4u0hR351HKwdKUR6yQhSgiFwIhAKyBxCus
      fkixpflzrNqoHf7P+ILUSCGiJUTHfXgWvUMx
      -----END CERTIFICATE-----
    ''
    ''
      Derpy Init CA
      =========
      -----BEGIN CERTIFICATE-----
      MIIBnTCCAUOgAwIBAgIRALOq6ggZ5QPICIU/3etEMmEwCgYIKoZIzj0EAwIwGDEW
      MBQGA1UEAxMNRGVycHkgUm9vdCBDQTAeFw0yMDEyMzEwMDI1NTNaFw0zMDEyMzEw
      MDI1NTNaMCAxHjAcBgNVBAMTFURlcnB5IEludGVybWVkaWF0ZSBDQTBZMBMGByqG
      SM49AgEGCCqGSM49AwEHA0IABIrRBVA30TKKw1YWkZuQ/2YfX2AY7jQba/C0/C7Q
      zH/epTCwT+BDkMLFHWibF+oNCJFu1CJiLC67lLlnWfLl/eOjZjBkMA4GA1UdDwEB
      /wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBT2iRyjwFE2R/c7
      6isazx3b3Et9ADAfBgNVHSMEGDAWgBRIKzZtEO0w/Pix8eLexR8kvDmdWDAKBggq
      hkjOPQQDAgNIADBFAiEA68oVuJ4b9ChgMjwIqjtlLwP/wPFow5O+w3FM20b63qQC
      IFYJqwzCiKJkmcV5Y+/lp663FuJ/pgXsIe+yiUVQAQu2
      -----END CERTIFICATE-----
    ''
    ''
      Red Hat CA
      =========
      -----BEGIN CERTIFICATE-----
      MIID6DCCAtCgAwIBAgIBFDANBgkqhkiG9w0BAQsFADCBpTELMAkGA1UEBhMCVVMx
      FzAVBgNVBAgMDk5vcnRoIENhcm9saW5hMRAwDgYDVQQHDAdSYWxlaWdoMRYwFAYD
      VQQKDA1SZWQgSGF0LCBJbmMuMRMwEQYDVQQLDApSZWQgSGF0IElUMRswGQYDVQQD
      DBJSZWQgSGF0IElUIFJvb3QgQ0ExITAfBgkqhkiG9w0BCQEWEmluZm9zZWNAcmVk
      aGF0LmNvbTAeFw0xNTEwMTQxNzI5MDdaFw00NTEwMDYxNzI5MDdaME4xEDAOBgNV
      BAoMB1JlZCBIYXQxDTALBgNVBAsMBHByb2QxKzApBgNVBAMMIkludGVybWVkaWF0
      ZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
      ggEKAoIBAQDYpVfg+jjQ3546GHF6sxwMOjIwpOmgAXiHS4pgaCmu+AQwBs4rwxvF
      S+SsDHDTVDvpxJYBwJ6h8S3LK9xk70yGsOAu30EqITj6T+ZPbJG6C/0I5ukEVIeA
      xkgPeCBYiiPwoNc/te6Ry2wlaeH9iTVX8fx32xroSkl65P59/dMttrQtSuQX8jLS
      5rBSjBfILSsaUywND319E/Gkqvh6lo3TEax9rhqbNh2s+26AfBJoukZstg3TWlI/
      pi8v/D3ZFDDEIOXrP0JEfe8ETmm87T1CPdPIZ9+/c4ADPHjdmeBAJddmT0IsH9e6
      Gea2R/fQaSrIQPVmm/0QX2wlY4JfxyLJAgMBAAGjeTB3MB0GA1UdDgQWBBQw3gRU
      oYYCnxH6UPkFcKcowMBP/DAfBgNVHSMEGDAWgBR+0eMgvlHoSCD3ri/GasNz824H
      GTASBgNVHRMBAf8ECDAGAQH/AgEBMA4GA1UdDwEB/wQEAwIBhjARBglghkgBhvhC
      AQEEBAMCAQYwDQYJKoZIhvcNAQELBQADggEBADwaXLIOqoyQoBVck8/52AjWw1Cv
      ath9NGUEFROYm15VbAaFmeY2oQ0EV3tQRm32C9qe9RxVU8DBDjBuNyYhLg3k6/1Z
      JXggtSMtffr5T83bxgfh+vNxF7o5oNxEgRUYTBi4aV7v9LiDd1b7YAsUwj4NPWYZ
      dbuypFSWCoV7ReNt+37muMEZwi+yGIU9ug8hLOrvriEdU3RXt5XNISMMuC8JULdE
      3GVzoNtkznqv5ySEj4M9WsdBiG6bm4aBYIOE0XKE6QYtlsjTMB9UTXxmlUvDE0wC
      z9YYKfC1vLxL2wAgMhOCdKZM+Qlu1stb0B/EF3oxc/iZrhDvJLjijbMpphw=
      -----END CERTIFICATE-----
    ''
  ];
}
