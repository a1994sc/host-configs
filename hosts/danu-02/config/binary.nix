{
  inputs,
  config,
  ...
}:
{
  age.secrets.binary = {
    file = (inputs.self.outPath + "/encrypt/binary/danu-02.key.age");
    mode = "0600";
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.binary.path;
  };

  services.nginx.virtualHosts."binary-cache-${config.ascii.system.cache.domain}" = {
    locations."/".proxyPass =
      "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";

    addSSL = true;
    sslTrustedCertificate = config.ascii.system.cache.ssl.fullchain;
    sslCertificateKey = config.ascii.system.cache.ssl.key;
    sslCertificate = config.ascii.system.cache.ssl.cert;
    listen = [
      {
        inherit (config.ascii.system.cache.ssl) port;
        addr = "0.0.0.0";
        ssl = true;
      }
    ];
  };
}
