{ config, self, ... }:
let
  name = "vroze";
in
{
  home-manager.users."${name}" = {
    imports = [ "${self}/users" ];
    home.username = name;
  };
  users = {
    groups.vroze = {
      inherit name;
      gid = config.users.users.vroze.uid;
    };
    users.vroze = rec {
      inherit name;
      # keep-sorted start block=yes case=no
      description = "Victoria Roze";
      extraGroups = [ ];
      group = name;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ ];
      uid = 1001;
      # keep-sorted end
    };
  };
}
