{
  inputs,
  system,
  config,
  ...
}:
{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGZ4rS2mbNzQYWtYxZIpDv+xLkI4UHLov8ICjH3FkkG";
    masterIdentities = [ ../../encrypt/ascii.pub ];
    storageMode = "local";
    localStorageDir = ./. + "/secrets";
  };

  age.secrets.randomPassword = {
    rekeyFile = ./secrets/randomPassword.age;
    generator.script = "passphrase";
  };
}
