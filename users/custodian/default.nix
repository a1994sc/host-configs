{ inputs, ... }:
let
  name = "custodian";
in
{
  imports = [ ./minimal.nix ];

  # user services need the session to survive logout
  users.users."${name}".linger = true;

  home-manager.users."${name}" = {
    imports = [ (inputs.self.outPath + "/users") ];
    home.username = name;
  };
}
