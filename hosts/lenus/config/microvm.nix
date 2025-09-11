{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    firecracker
    firectl
  ];
  # microvm.hypervisor = "firecracker";
}
