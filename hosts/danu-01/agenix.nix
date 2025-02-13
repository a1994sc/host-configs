{ inputs, system, ... }:
{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
}
