{
  inputs,
  system,
  config,
  ...
}:
{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgtCFdGSN+0iuaD6WpspN7tB7bZk0nuUqeY4Mq7k5Df";
    masterIdentities = [ ../../encrypt/ascii.pub ];
    storageMode = "local";
    localStorageDir = ./. + "/secrets";
  };
}
