{ config, pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "get-talos" ''
      set -eou pipefail

      VERSION=''${1:-"v1.5.1"}
      DEST_DIR=''${2:-"$PWD/assets"}
      DEST=$DEST_DIR/talos/$VERSION
      BASE_URL=https://github.com/siderolabs/talos/releases/download/$VERSION


      # check stream/version exist based on the header response
      if ! ${pkgs.curl}/bin/curl -s -I $BASE_URL/initramfs-amd64.xz | ${pkgs.busybox}/bin/grep -q -E '^HTTP/[0-9.]+ [23][0-9][0-9]' ; then
        ${pkgs.coreutils}/bin/echo "Version not found"
        exit 1
      fi

      if [ ! -d "$DEST" ]; then
        ${pkgs.coreutils}/bin/echo "Creating directory $DEST"
        ${pkgs.coreutils}/bin/mkdir -p $DEST
      fi

      ${pkgs.coreutils}/bin/echo "Downloading Talos $VERSION images to $DEST"

      # PXE vmlinuz AMD64
      ${pkgs.coreutils}/bin/echo "vmlinuz-amd64"
      ${pkgs.curl}/bin/curl -L -# $BASE_URL/vmlinuz-amd64 -o $DEST/vmlinuz-amd64

      # PXE vmlinuz ARM64
      ${pkgs.coreutils}/bin/echo "vmlinuz-arm64"
      ${pkgs.curl}/bin/curl -L -# $BASE_URL/vmlinuz-amd64 -o $DEST/vmlinuz-arm64

      # PXE initramfs AMD64
      ${pkgs.coreutils}/bin/echo "initramfs-amd64.xz"
      ${pkgs.curl}/bin/curl -L -# $BASE_URL/initramfs-amd64.xz -o $DEST/initramfs-amd64.xz

      # PXE initramfs ARM64
      ${pkgs.coreutils}/bin/echo "initramfs-arm64.xz"
      ${pkgs.curl}/bin/curl -L -# $BASE_URL/initramfs-amd64.xz -o $DEST/initramfs-arm64.xz

      ${pkgs.coreutils}/bin/chown ${config.users.users.matchbox.name}:${config.users.groups.matchbox.name} -R $DEST_DIR
    '')
    (pkgs.writeShellScriptBin "get-fedoracore" ''
      set -eou pipefail

      STREAM=''${1:-"stable"}
      VERSION=''${2:-"38.20230806.3.0"}
      DEST_DIR=''${3:-"$PWD/assets"}
      DEST=$DEST_DIR/fedora-coreos
      BASE_URL=https://builds.coreos.fedoraproject.org/prod/streams/$STREAM/builds/$VERSION

      # check stream/version exist based on the header response
      if ! ${pkgs.curl}/bin/curl -s -I $BASE_URL/x86_64/fedora-coreos-$VERSION-metal.x86_64.raw.xz | ${pkgs.busybox}/bin/grep -q -E '^HTTP/[0-9.]+ [23][0-9][0-9]' ; then
        ${pkgs.coreutils}/bin/echo "Stream or Version not found"
        exit 1
      fi

      if [ ! -d "$DEST" ]; then
        ${pkgs.coreutils}/bin/echo "Creating directory $DEST"
        ${pkgs.coreutils}/bin/mkdir -p $DEST
      fi

      ${pkgs.coreutils}/bin/echo "Downloading Fedora CoreOS $STREAM $VERSION images to $DEST"

      # PXE kernel
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-kernel-x86_64"
      ${pkgs.curl}/bin/curl -# $BASE_URL/x86_64/fedora-coreos-$VERSION-live-kernel-x86_64 -o $DEST/fedora-coreos-$VERSION-live-kernel-x86_64
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-kernel-aarch64"
      ${pkgs.curl}/bin/curl -# $BASE_URL/aarch64/fedora-coreos-$VERSION-live-kernel-aarch64 -o $DEST/fedora-coreos-$VERSION-live-kernel-aarch64

      # PXE initrd
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-initramfs.x86_64.img"
      ${pkgs.curl}/bin/curl -# $BASE_URL/x86_64/fedora-coreos-$VERSION-live-initramfs.x86_64.img -o $DEST/fedora-coreos-$VERSION-live-initramfs.x86_64.img
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-initramfs.aarch64.img"
      ${pkgs.curl}/bin/curl -# $BASE_URL/aarch64/fedora-coreos-$VERSION-live-initramfs.aarch64.img -o $DEST/fedora-coreos-$VERSION-live-initramfs.aarch64.img

      # rootfs
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-rootfs.x86_64.img"
      ${pkgs.curl}/bin/curl -# $BASE_URL/x86_64/fedora-coreos-$VERSION-live-rootfs.x86_64.img -o $DEST/fedora-coreos-$VERSION-live-rootfs.x86_64.img
      ${pkgs.coreutils}/bin/echo "fedora-coreos-$VERSION-live-rootfs.aarch64.img"
      ${pkgs.curl}/bin/curl -# $BASE_URL/aarch64/fedora-coreos-$VERSION-live-rootfs.aarch64.img -o $DEST/fedora-coreos-$VERSION-live-rootfs.aarch64.img

      ${pkgs.coreutils}/bin/chown ${config.users.users.matchbox.name}:${config.users.groups.matchbox.name} -R $DEST_DIR
    '')
    (pkgs.writeShellScriptBin "get-flatcar" ''
      set -eou pipefail

      CHANNEL=''${1:-"stable"}
      VERSION=''${2:-"current"}
      DEST_DIR=''${3:-"$PWD/assets"}
      OEM_ID=''${OEM_ID:-""}
      DEST=$DEST_DIR/flatcar/$VERSION
      BASE_URL=https://$CHANNEL.release.flatcar-linux.net

      # check channel/version exist based on the header response
      if ! ${pkgs.curl}/bin/curl -s -I "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_pxe.vmlinuz" | ${pkgs.busybox}/bin/grep -q -E '^HTTP/[0-9.]+ [23][0-9][0-9]'; then
        ${pkgs.coreutils}/bin/echo "Channel or Version not found"
        exit 1
      fi

      if [[ ! -d "$DEST" ]]; then
        ${pkgs.coreutils}/bin/echo "Creating directory ''${DEST}"
        ${pkgs.coreutils}/bin/mkdir -p "''${DEST}"
      fi

      if [[ -n "''${OEM_ID}" ]]; then
        IMAGE_NAME="flatcar_production_''${OEM_ID}_image.bin.bz2"

        # check if the oem version exists based on the header response
        if ! ${pkgs.curl}/bin/curl -s -I "''${BASE_URL}/''${IMAGE_NAME}" | ${pkgs.busybox}/bin/grep -q -E '^HTTP/[0-9.]+ [23][0-9][0-9]'; then
          ${pkgs.coreutils}/bin/echo "OEM version not found"
          exit 1
        fi
      fi

      ${pkgs.coreutils}/bin/echo "Downloading Flatcar Linux $CHANNEL $VERSION images and sigs to $DEST"

      ${pkgs.coreutils}/bin/echo "Flatcar Linux Image Signing Key"
      ${pkgs.curl}/bin/curl -# https://www.flatcar.org/security/image-signing-key/Flatcar_Image_Signing_Key.asc -o "''${DEST}/Flatcar_Image_Signing_Key.asc"
      ${pkgs.gnupg}/bin/gpg --import <"$DEST/Flatcar_Image_Signing_Key.asc" || true

      # Version
      ${pkgs.coreutils}/bin/echo "version.txt"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/version.txt" -o "''${DEST}/version.txt"

      # PXE kernel and sig
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe.vmlinuz..."
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_pxe.vmlinuz" -o "''${DEST}/flatcar_production_pxe.vmlinuz"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe.vmlinuz.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_pxe.vmlinuz.sig" -o "''${DEST}/flatcar_production_pxe.vmlinuz.sig"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe.arm64.vmlinuz..."
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_pxe.vmlinuz" -o "''${DEST}/flatcar_production_pxe.arm64.vmlinuz"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe.arm64.vmlinuz.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_pxe.vmlinuz.sig" -o "''${DEST}/flatcar_production_pxe.arm64.vmlinuz.sig"

      # PXE initrd and sig
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe_image.cpio.gz"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_pxe_image.cpio.gz" -o "''${DEST}/flatcar_production_pxe_image.cpio.gz"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe_image.cpio.gz.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_pxe_image.cpio.gz.sig" -o "''${DEST}/flatcar_production_pxe_image.cpio.gz.sig"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe_image.arm64.cpio.gz"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_pxe_image.cpio.gz" -o "''${DEST}/flatcar_production_pxe_image.arm64.cpio.gz"
      ${pkgs.coreutils}/bin/echo "flatcar_production_pxe_image.arm64.cpio.gz.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_pxe_image.cpio.gz.sig" -o "''${DEST}/flatcar_production_pxe_image.arm64.cpio.gz.sig"

      # Install image
      ${pkgs.coreutils}/bin/echo "flatcar_production_image.bin.bz2"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_image.bin.bz2" -o "''${DEST}/flatcar_production_image.bin.bz2"
      ${pkgs.coreutils}/bin/echo "flatcar_production_image.bin.bz2.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/flatcar_production_image.bin.bz2.sig" -o "''${DEST}/flatcar_production_image.bin.bz2.sig"
      ${pkgs.coreutils}/bin/echo "flatcar_production_image.arm64.bin.bz2"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_image.bin.bz2" -o "''${DEST}/flatcar_production_image.arm64.bin.bz2"
      ${pkgs.coreutils}/bin/echo "flatcar_production_image.arm64.bin.bz2.sig"
      ${pkgs.curl}/bin/curl -# "''${BASE_URL}/arm64-usr/$VERSION/flatcar_production_image.bin.bz2.sig" -o "''${DEST}/flatcar_production_image.arm64.bin.bz2.sig"

      # Install oem image
      if [[ -n "''${IMAGE_NAME-}" ]]; then
        ${pkgs.coreutils}/bin/echo "''${IMAGE_NAME}"
        ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/''${IMAGE_NAME}" -o "''${DEST}/''${IMAGE_NAME}"
        ${pkgs.coreutils}/bin/echo "''${IMAGE_NAME}.sig"
        ${pkgs.curl}/bin/curl -# "''${BASE_URL}/amd64-usr/$VERSION/''${IMAGE_NAME}.sig" -o "''${DEST}/''${IMAGE_NAME}.sig"
      fi

      # verify signatures
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_pxe.vmlinuz.sig"
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_pxe.arm64.vmlinuz.sig"
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_pxe_image.cpio.gz.sig"
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_pxe_image.arm64.cpio.gz.sig"
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_image.bin.bz2.sig"
      ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/flatcar_production_image.arm64.bin.bz2.sig"

      # verify oem signature
      if [[ -n "''${IMAGE_NAME-}" ]]; then
        ${pkgs.gnupg}/bin/gpg --verify "''${DEST}/''${IMAGE_NAME}.sig"
      fi

      ${pkgs.coreutils}/bin/chown ${config.users.users.matchbox.name}:${config.users.groups.matchbox.name} -R $DEST_DIR
    '')
  ];
}
