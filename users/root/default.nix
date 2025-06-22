{ inputs, ... }:
{
  imports = [ (inputs.self.outPath + "/users") ];
  home.username = "root";
}
