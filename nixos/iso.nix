{ modulesPath, pkgs, ... }:
{
  imports = [
    # This profile already sets boot.kernelPackages = pkgs.linuxPackages_latest,
    # which on nixos-unstable (2026-04) is mainline Linux 7.0+.
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lshw
  ];
}
