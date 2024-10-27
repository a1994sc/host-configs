{ config, ... }:
{
  users = {
    extraUsers.ascii = {
      subUidRanges = [
        {
          startUid = config.users.users.ascii.uid * 10;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = config.users.users.ascii.uid * 10;
          count = 65536;
        }
      ];
    };
    groups.ascii = {
      gid = config.users.users.ascii.uid;
      name = "ascii";
    };
    users.ascii = {
      isNormalUser = true;
      description = "Allen Conlon";
      uid = 1000;
      extraGroups = [
        # keep-sorted start
        "dialout"
        "docker"
        "networkmanager"
        "wheel"
        # keep-sorted end
      ];
      openssh.authorizedKeys.keys = [
        # keep-sorted start
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACa5MIyu4mLLLc0D5Y0eOWV1JnvvSo68pDJAh4SyC1WyMVK1eOIlpyDlfFNu7wev8fPELJEwbT+pCsjH2FVU8qRNAH17nW1EBn9xWOX7rEnpxOp6X485+jeA0t/a2jB6e7Bcn86Xwa1tPEbIKS6eo530KMLagaCFpl9arv1SGWeh6/YAw== aconlon@puck.adrp.xyz"
        "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAF/R3bjaZYUB6cJe7jcexHc+n+zk+F+39SH55nHWk1uqX5h+/YSkDlDPl42QfVVcV/kyX21yv3zUO3zl6h+OsDltgH9+VggOJSvrYYWLx5vb9H3gH6y3yfc2V8Eyg6v4svSE2z6SbRmQw/bLmCcCU+C+oC74du/a/VJocT4ib706LMG2A== aconlon@omga.ardp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhw1oW+L4T2IyjKKx8umgMXtrDZQRxvmR/k7NdF6ZIk sync"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ+ijO8h19n6GB9am9cek91WjLvpn80w3Y5XthK3Tpo/ jump@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTN+22xUz/NIZ/+E3B7bSQAl1Opxg0N7jIVGlAxTJw2 git@conlon.dev"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpoTjm581SSJi51VuyDXkGj+JThQOavxicFgK1Z/YlN pihole@adrp.xyz"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEVDFj/DsBQNjAoid6lbcJhWWyx5Gq6VzSJGKvK+bR6 pixel7@adrp.xyz"
        # keep-sorted end
      ];
    };
  };
}
