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
    danu-01 = [ ];
    danu-02 = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0ZBelmFfxNY5Yi1HJZhRAZx60wCt2FUSLRm1Z+FPtq"
      "age1fq9c5nsmxmdn6khjjf2gjzkfgswrf6herkrr5kdpj70p6xz4gdusz4pd70"
    ];
    # keep-sorted end
  };
  secrets = {
    # keep-sorted start
    "matchbox/ca.crt" = machines.danu-02;
    "matchbox/tls.crt" = machines.danu-02;
    "matchbox/tls.key" = machines.danu-02;
    "matchbox/env" = machines.danu-02;
    "step-ca/pass" = machines.danu-02;
    "step-ca/ca.key" = machines.danu-02;
    "step-ca/tls.crt" = machines.danu-02;
    "step-ca/tls.key" = machines.danu-02;
    "powerdns/primary.env" = machines.danu-01;
    "powerdns/primary.replica" = machines.danu-01;
    "powerdns/replica.env" = machines.danu-02;
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
