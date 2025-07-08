{
  pkgs,
  lib,
  ...
}:
{
  hardware.graphics = {
    # driSupport = true;
    enable32Bit = true;
    # amdvlk: an open-source Vulkan driver from AMD
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
  programs = {
    gnome-disks.enable = true;
    file-roller.enable = true;
    hyprland.enable = true;
    mtr.enable = true;
  };
  services = {
    # keep-sorted start block=yes case=no
    fwupd.enable = true;
    xserver = {
      enable = true;
    };
    # keep-sorted end
  };
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    # sddm.settings.General.DisplayServer = "wayland";
    defaultSession = "plasma";
  };
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "amdgpu" ];
    displayManager.lightdm.enable = lib.mkForce false;
    excludePackages = [ pkgs.xterm ];
  };
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  environment.sessionVariables.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  environment.sessionVariables.NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  environment.plasma6.excludePackages = [
    pkgs.kdePackages.kunifiedpush
  ];
}
