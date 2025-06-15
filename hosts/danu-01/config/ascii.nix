{
  inputs,
  system,
  lib,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
in
{
  imports = [
    (inputs.self.outPath + "/modules")
  ];

  ascii = {
    system = {
      bare.enable = true;
      dns.enable = true;
      cache = {
        enable = false;
        domain = "danu-01.adrp.xyz";
        sans = [
          "10.3.10.5"
          "10.3.20.5"
          "100.89.86.119"
        ];
        ssl.enable = true;
        alts = {
          # keep-sorted start block=yes
          "ascii" = {
            url = "https://a1994sc.cachix.org";
            key = "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI=";
          };
          "community" = {
            url = "https://nix-community.cachix.org";
            key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
          };
          "numtide" = {
            url = "https://numtide.cachix.org";
            key = "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=";
          };
          "terra" = {
            url = "https://nixpkgs-terraform.cachix.org";
            key = "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";
          };
          # keep-sorted end
        };
      };
      step = {
        enable = false;
        dnsNames = [
          "10.3.10.5"
          "10.3.20.5"
          "danu-01.adrp.xyz"
        ];
        age.pass = inputs.self.outPath + "/encrypt/step-ca/pass.age";
        age.key = inputs.self.outPath + "/encrypt/step-ca/ca.key.age";
      };
      getty.enable = true;
    };
    security.certs = {
      enable = false;
      name = "danu-01.adrp.xyz";
      sans =
        [
          "10.3.10.5"
          "10.3.20.5"
          "100.89.86.119"
          "keycloak.danu-01.adrp.xyz"
          "api.danu-01.adrp.xyz"
          "omni.danu-01.adrp.xyz"
          "kube.danu-01.adrp.xyz"
        ]
        ++ (lib.lists.unique (
          builtins.map (alt: "${alt}.${danu-01.domain}") (builtins.attrNames danu-01.alts)
        ));
    };
  };
}
