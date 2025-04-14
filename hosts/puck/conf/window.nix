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
  environment.sessionVariables = {
    # WAYLAND_DISPLAY = "wayland-0";
    QT_QPA_PLATFORM = "wayland"; # Qt Applications
    GDK_BACKEND = "wayland"; # GTK Applications
    XDG_SESSION_TYPE = "wayland"; # Electron Applications
  };
}
