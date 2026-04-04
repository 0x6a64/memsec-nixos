# MEMSEC DEFCON 901 - Reproducible Cybersecurity Labs with Nix/NixOS
## Links
- [Google Slides](https://docs.google.com/presentation/d/1ZMD2qqvC_lNjxgHcgkHcSmFm7GKk3nHiLQejDzHepBA/edit?usp=sharing) (Most up-to-date source, incl. slide notes)

PDF/PPTX in repo

Other artifacts will be uploaded here if relevant

# Q/A Answers:
#### Can BSD run nix?
- There is some support for Nix on *BSD and nix is in FreeBSD ports collection but it is not really mature and lacking some feature parity with Linux. Also most of the nix CI/CD testing happens on Linux so it is harder to test for edge cases. That being said it seems the most active project in this space is nixbsd
  - [NixOS-BSD](https://github.com/nixos-bsd/nixbsd)
 
#### Does Nix deduplicate dependencies like identical libraries that are shared by applications?
- If two packages depend on the exact same version of, say, glibc built with the exact same configuration, they both point to the same store path. There's only one copy on disk. If you have two slightly different builds of the same library (different compile flags, patches, or even just a different Nixpkgs revision), Nix treats them as completely separate store paths. You'll have two copies on disk. This is by design for reproducibility, but it does mean the store can grow. `nix-store --optimise`: Nix provides a built-in hardlink-based deduplication pass. This scans the store for files with identical content (regardless of which package they belong to) and replaces duplicates with hardlinks. You can also replace this with a line in your configuration so you don't need to run it manually. (`nix.settings.auto-optimise-store = true;`) Nix also has garbage collection to remove nix store items that are no longer required and this can also be set in your main config. (`nix.gc.options = "--delete-older-than 30d";`)

# Live Demo Post-Mortem: NixOS VM Builds

## What happened

During the live presentation, two VM build demos failed:

1. **NixIso (`~/Code/Nixiso`)** - `nixos-rebuild build-vm` with no flags and with a flake specification but no hostname specification
2. **Nixos (`~/Nixos`)** - `nixos-rebuild build-vm --flake ~/Nixos#gearhead`

---

## Demo 1: NixIso — `nixos-config` not found

### Command run

```sh
nixos-rebuild build-vm

nixos-rebuild build-vm .
```

### Error

```
error: file 'nixos-config' was not found in the Nix search path (add it using $NIX_PATH or -I)
```

### Root cause

`nixos-rebuild build-vm` without `--flake` uses the legacy channel/`NIX_PATH` lookup to find the system configuration. Since NixIso is a flake-based project with no channel configuration, Nix had nowhere to find `nixos-config`.

### What should have been run

```sh
nixos-rebuild build-vm --flake .#live-iso
```

However, this would have hit a **second issue**: the `live-iso` configuration imports `installation-cd-minimal.nix`, which is an ISO installer module — not a VM-compatible system configuration. The ISO module defines `system.build.isoImage`, not `system.build.vm`.

### Fix

A separate `nixosConfigurations.vm` entry was needed in `flake.nix` that:

- Imports `profiles/qemu-guest.nix` instead of `installation-cd-minimal.nix`
- Reuses `iso-configuration.nix` for all the shared config (packages, GNOME, theming, etc.)
- Adds a root filesystem (`fileSystems."/"`) and bootloader (`boot.loader.grub.device`) that VMs require

**Correct command with the fix applied:**

```sh
nixos-rebuild build-vm --flake .#vm
```

---

## Demo 2: Nixos (gearhead) btrfs assertion failure (Build of my main machine image)

### Command run

```sh
nixos-rebuild build-vm --flake ~/Nixos#gearhead
```

### Error

```
Failed assertions:
- If 'services.btrfs.autoScrub' is enabled, you need to have at least one
  btrfs file system mounted via 'fileSystems' or specify a list manually
  in 'services.btrfs.autoScrub.fileSystems'.
```

### Root cause

The `gearhead` configuration enables `services.btrfs.autoScrub`, which requires btrfs filesystems to be defined in `fileSystems`. The real system has these via disko, but when building a VM variant, NixOS creates a virtual disk with its own filesystem layout none of which are btrfs. The assertion fires because the VM variant has no btrfs mounts and honestly my configuration may be too complex or out there at this point to run cleanly in an automatically generated nix VM.

### Fix

Override the btrfs scrub setting for the VM variant only, so the real system config stays unchanged:

```nix
# Add to the gearhead modules list in flake.nix
{
  virtualisation.vmVariant = {
    services.btrfs.autoScrub.enable = lib.mkForce false;
  };
}
```

Additional hardware-specific options (disko partitioning, lanzaboote secure boot, impermanence, etc.) may also need `mkForce` overrides inside `virtualisation.vmVariant` as they surface.

---

## VM Configuration changes 

### `flake.nix` — replaced ISO config with VM config

The `nixosConfigurations.live-iso` entry (which used `installation-cd-minimal.nix`) was replaced with a `nixosConfigurations.vm` entry:

```nix
nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inputs = { inherit nixpkgs llm-agents; }; };
  modules = [
    ({ modulesPath, ... }: {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")  # <-- instead of installation-cd-minimal.nix
        ./iso-configuration.nix
      ];

      # VM needs a root filesystem and bootloader
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      boot.loader.grub.device = "/dev/vda";

      # VM display and resource settings
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 2;
          qemu.options = [
            "-vga virtio"
          ];
        };
      };
    })
  ];
};
```

Key changes:
- `profiles/qemu-guest.nix` replaces `installation-cd-minimal.nix` to provide virtio drivers and guest agent setup for QEMU
- `fileSystems."/"` and `boot.loader.grub.device` are required because the ISO module normally provides its own root filesystem, but a VM config needs one explicitly
- `virtualisation.vmVariant` wraps the VM tuning options: `virtualisation.cores`, `memorySize`, etc. are only available inside `vmVariant`

### `iso-configuration.nix` — removed `isoImage` block

The `isoImage` settings are ISO-specific and cause errors in a VM context. This block was removed:

```nix
# Removed from iso-configuration.nix
isoImage = {
  makeEfiBootable = true;
  makeUsbBootable = true;
  makeBiosBootable = true;
  squashfsCompression = "zstd -Xcompression-level 6";
  volumeID = "NIXOS-LIVE";
  edition = "dev-environment";
};
```

Everything else in `iso-configuration.nix` (GNOME, theming, packages, users, networking, etc.) was kept as-is.

### Build and run

```sh
cd ~/Code/Nixiso-VM
nixos-rebuild build-vm --flake .#vm
./result/bin/run-nixos-live-vm
```
