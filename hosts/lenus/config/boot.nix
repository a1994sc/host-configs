{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  boot = {
    # pkgs.linuxPackages_zen
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = true;
    binfmt.preferStaticEmulators = true;
    binfmt.emulatedSystems = [
      "wasm32-wasi"
      "aarch64-linux"
    ];
  };
  services.udev = {
    extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="1260", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12ad", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="1252", TAG+="uaccess"
    '';
    packages = [
      pkgs.yubikey-personalization
      pkgs.headsetcontrol
      pkgs.logitech-udev-rules
    ];
  };
  system.autoUpgrade = {
    # keep-sorted start block=yes case=no
    dates = "02:00";
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L"
    ];
    flake = inputs.self.outPath;
    randomizedDelaySec = "45min";
    # keep-sorted end
  };
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
}
