{ inputs, system, ... }:
{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
  age.secrets.nginx-htpasswd = {
    file = ../../encrypt/matchbox/ca.crt.age;
    mode = "770";
    # owner = "nginx";
    # group = "nginx";
  };
}
