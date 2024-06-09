{ pkgs, inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    age
    gnupg
  ];

  sops.age.keyFile = "/home/custodian/.config/sops/age/keys.txt";
}
