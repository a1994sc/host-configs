{ config, ... }:
{
  users = {
    groups.vroze = {
      gid = config.users.users.vroze.uid;
      inherit (config.users.users.vroze) name;
    };
    users.vroze = rec {
      # keep-sorted start block=yes case=no
      description = "Victoria Roze";
      extraGroups = [ ];
      group = name;
      isNormalUser = true;
      name = "vroze";
      openssh.authorizedKeys.keys = [ ];
      uid = 1001;
      # keep-sorted end
    };
  };
}
