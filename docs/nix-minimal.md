# Minimal

How far a NixOS appliance can be stripped, measured on `danu-01` (a Dell 3070 thin
client running nothing but blocky and comin). Numbers are NAR sizes from
`nix path-info --json` on `system.build.toplevel`, nixpkgs 26.05.

## What is left running

Twelve units are wanted by `multi-user.target`:

```
blocky  comin  sshd + sshd-keygen  systemd-networkd  nsncd
resolvconf  systemd-sysctl  systemd-modules-load
linger-users  reload-systemd-vconsole-setup  post-boot
```

Plus the systemd core that is not worth fighting: udev, journald, timesyncd,
dbus-broker, logind. `nsncd` backs NSS, `timesyncd` keeps the clock sane enough
for blocky to validate its DNS-over-TLS upstreams, and journald is the only
debugging surface on a box with no console.

## The knobs that paid

Applied in `hosts/danu-0*/config/configuration.nix` and
`hardware-configuration.nix`:

| Knob | Effect |
| --- | --- |
| `imports = [ (modulesPath + "/profiles/minimal.nix") ]` | drops docs, `environment.defaultPackages` (perl, rsync, strace), logrotate, udisks2, command-not-found, stub-ld |
| `hardware.enableRedistributableFirmware = false` | ~400 MiB of blobs; a wired Intel/Realtek NIC needs none |
| `hardware.cpu.intel.updateMicrocode = true` | set explicitly, because `not-detected.nix` ties it to the firmware flag above |
| `nixpkgs.flake.setFlakeRegistry = false`<br>`nixpkgs.flake.setNixPath = false` | 198 MiB — `/etc/nix/registry.json` otherwise pins a whole copy of nixpkgs into the closure |
| `services.userborn.enable = true`<br>`system.etc.overlay.enable = true`<br>`boot.initrd.systemd.enable = true` | removes both perl activation scripts (`setup-etc.pl`, `update-users-groups.pl`). The overlay needs initrd systemd |
| `systemd.oomd.enable = false` | nothing here to pressure-manage |
| `boot.enableContainers = false`, `nix.channel.enable = false`, `system.disableInstallerTools = true`, `system.tools.nixos-generate-config.enable = false` | a unit here, a tool there |

Closure went 1.2 GiB → 1.0 GiB.

## Where the remaining 1.0 GiB sits

```
144 MiB  linux-modules        128 MiB  python3     60 MiB  systemd
 55 MiB  perl                  55 MiB  git         42 MiB  initrd
 38 MiB  icu4c                 33 MiB  glibc       27 MiB  blocky
 22 MiB  comin                 22 MiB  kernel
```

**comin is the biggest remaining lever.** It depends on the git CLI, which drags
in python3 (git-p4) and perl (git-send-email): 238 MiB, a quarter of the system.
Deploying with `nixos-rebuild --target-host` instead would take all three out.
The flip side is that `pkgs.git` in `PATH` costs nothing while comin stays.

## What is not worth doing

- **A trimmed kernel.** There is no supported option to strip the module tree —
  only `boot.kernelPackages = linuxPackagesFor (linux.override { structuredExtraConfig = ...; })`,
  which means each host builds its own kernel on every bump. These boxes have no
  binary cache anymore, so 144 MiB is not worth a local kernel build.
- **`profiles/perlless.nix`.** Its `forbiddenDependenciesRegexes = [ "perl" ]`
  fails the build on comin's git. Take its three mechanics (userborn, etc
  overlay, initrd systemd) and leave the assertion.
- **`profiles/headless.nix`.** It disables `getty@tty1` and sets `nomodeset`,
  which leaves no local console on a machine you may have to walk to.

## Measuring it yourself

```sh
nix build --no-link --print-out-paths .#nixosConfigurations.danu-01.config.system.build.toplevel
nix path-info -Sh /nix/store/...-nixos-system-danu-01-...            # closure size
nix why-depends  /nix/store/...-nixos-system-danu-01-... nixpkgs#perl # who dragged it in
```

`nix why-depends --derivation` answers a different question — build inputs, not
the runtime closure — so it will show perl even on a system that ships without
it. Build first, then ask.
