{
  inputs,
  system,
  ...
}:
{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  age.secrets.random-password = {
    rekeyFile = ./secrets/random-password.age;
    generator.script = "passphrase";
  };
}
