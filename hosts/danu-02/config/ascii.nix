{
  inputs,
  system,
  outputs,
  ...
}:
let
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
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
        domain = "danu-02.adrp.xyz";
        sans = [
          "10.3.10.6"
          "10.3.20.6"
          "100.126.110.27"
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
    };
    security.certs = {
      enable = false;
      name = "danu-02.adrp.xyz";
      sans = [
        "10.3.10.6"
        "10.3.20.6"
        "100.126.110.27"
      ] ++ (builtins.map (alt: "${alt}.${danu-02.domain}") (builtins.attrNames danu-02.alts));
    };
  };
}
