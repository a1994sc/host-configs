{
  inputs,
  config,
  ...
}:
{
  age.secrets.binary = {
    file = (inputs.self.outPath + "/encrypt/binary/danu-01.key.age");
    mode = "0600";
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.age.secrets.binary.path;
  };
}
