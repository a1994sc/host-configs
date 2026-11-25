{ inputs, ... }:
let
  name = "custodian";
in
{
  imports = [ ./minimal.nix ];

  home-manager.users."${name}" = {
    imports = [ (inputs.self.outPath + "/users") ];
    home.username = name;
  };
}
