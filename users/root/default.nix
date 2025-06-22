{ inputs, ... }:
let
  name = "root";
in
{
  home-manager.users."${name}" = {
    imports = [ (inputs.self.outPath + "/users") ];
    home.username = name;
  };
}
