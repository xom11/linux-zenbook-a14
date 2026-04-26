# Minimal NixOS Boot-Test ISO for ASUS ZenBook A14

Goal: produce the smallest aarch64 NixOS installer ISO that **boots** on this hardware. No firmware, no out-of-tree modules, no desktop — just kernel + busybox-style installer.

The official NixOS 25.11 ISO ships with kernel 6.12 LTS, which lacks the `x1p42100-asus-zenbook-a14` device tree (merged via the 6.18 cycle). This flake forces `linuxPackages_latest` from `nixos-unstable`, which currently points at mainline Linux 7.0+.

## Files

| File | Purpose |
|---|---|
| `flake.nix` | Pin nixpkgs (unstable) + define ISO output |
| `iso.nix`   | Import minimal-installer profile + override kernel |

## Build

Run on the A14 itself (native aarch64), or on any other aarch64-linux machine:

```bash
cd nixos
nix build .#default
ls -lh result/iso/
```

Output: `result/iso/nixos-zenbook-a14-min-*.iso` (~800MB–1.2GB).

## Flash to USB

```bash
sudo dd if=result/iso/nixos-zenbook-a14-min-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your USB device (verify with `lsblk`).

## What this ISO does NOT include

Deliberately excluded — to be added back in `configuration.nix` after install succeeds:

- Adreno GPU firmware (Qualcomm-proprietary, requires manual download)
- `hid-asus-ec` Fn-keys kernel module
- Audio (audioreach-topology, alsa-ucm-conf overrides)
- Wi-Fi firmware and quirks

If first boot fails, the problem is kernel/DT — not these.
