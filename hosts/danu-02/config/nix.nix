{
  system,
  outputs,
  ...
}:
let
  danu-01 = outputs.nixosConfigurations.danu-01.config.ascii.system.cache;
  danu-02 = outputs.nixosConfigurations.danu-02.config.ascii.system.cache;
in
{
  nix.gc.dates = "Tue 02:00";
  # nix.settings.substituters =
  #   [
  #     "https://${danu-01.domain}?priority=15"
  #     "https://${danu-02.domain}?priority=10"
  #   ]
  #   ++ (builtins.map (alt: "https://${alt}.${danu-01.domain}?priority=15") (
  #     builtins.attrNames danu-01.alts
  #   ))
  #   ++ (builtins.map (alt: "https://${alt}.${danu-02.domain}?priority=10") (
  #     builtins.attrNames danu-02.alts
  #   ));
}
