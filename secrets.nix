let
  attr = builtins.listToAttrs (
    map (secretName: {
      name = "encrypt/${secretName}.age";
      value.publicKeys = secrets."${secretName}" ++ system.allen;
    }) (builtins.attrNames secrets)
  );
  # keep-sorted start block=yes
  machines = {
    # keep-sorted start block=yes
    danu-01 = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgtCFdGSN+0iuaD6WpspN7tB7bZk0nuUqeY4Mq7k5Df"
      "age1smp9h8cudflpdzks2dgvgd698vlnz0487t3xznyx9slx8kz87d5q264uwg"
    ];
    danu-02 = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGZ4rS2mbNzQYWtYxZIpDv+xLkI4UHLov8ICjH3FkkG"
      "age1phst52j05jgsjte2kgqu9v7kmhyndd2s3pm83mamdj0ts9avqpqsrwre93"
    ];
    # keep-sorted end
  };
  secrets = {
    # keep-sorted start
    "keycloak/base.word" = machines.danu-01;
    "omni/bare-metal.env" = machines.danu-01;
    "omni/etcd.asc" = machines.danu-01;
    "step-ca/ca.key" = machines.danu-01;
    "step-ca/pass" = machines.danu-01;
    "step-ca/tls.crt" = machines.danu-01;
    "step-ca/tls.key" = machines.danu-01;
    # keep-sorted end
  };
  # keep-sorted end
  system = {
    allen = [
      "age1yubikey1q20jh97qrk9kspzfmh4hrs8qgvuq34lvhm2pum9dae7p97gq78tsghyyha3"
      "age1yubikey1qf42tcrzealy89zpmat6c9fzza9pgt8f3nwl42pvj7sk7lllf623vmjq30d"
      "age1yubikey1q0kv8am08zj3pdakl8407xd8j0qxxytzwqx09vrtk64dsw2r5qragk5kd4f"
      "age1wjqegc62gpyvp4yfdqfk4vclfgdh3awlv03rgthcje398a860p7qpglp6w"
      "age1tp5ln7rhy9y0w7lgtamtgjn4w4sajlm36fj0le4smf3hf0hlf4ysq03uhh"
      "age1758tal2rl0ew693xt6l2ffwnrua33sxr6tc4ta3utu639ldfq53szvgm0g"
      "age1q5urgt9hszq2j9p2qtprl853w6gcy9wapzt73r73xmjla4zhq98scpl8rm"
    ];
  };
in
attr
