{
  pkgs,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      headsetcontrol
    ];
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services = {
    # keep-sorted start block=yes case=no
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      extraConfig.pipewire = {
        "99-silent-bell" = {
          "context.properties" = {
            "module.x11.bell" = false;
          };
        };
      };
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };
    # keep-sorted end
  };
}
