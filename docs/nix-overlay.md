# Overlays

> Overlays are Nix functions which accept two arguments, conventionally called `final` and `prev` (formerly also `self` and `super`), and return a set of packages. ... Overlays are similar to other methods for customizing Nixpkgs, in particular the packageOverrides ... Indeed, packageOverrides acts as an overlay with only the `prev` (`super`) argument. It is therefore appropriate for basic use, but overlays are more powerful and easier to distribute.
>
> --- From the [Nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#sec-overlays-definition)

A sort of too long didn't read is that with overlays you are able to change various parts of packages/modules.

## Unstable builds

A practical example would be enabling the ability to remain on the stable channel, but to pull in `unstable` packages.

In the `flake.nix` you need to add a new input for the `unstable` channel.

```nix
inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
```

After you can add the following to your configuration file.

```nix
{
  nixpkgs.overlays = [
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      };
    })
  ];
}
```

This will add the ability to pull unstable packages by the following.

```nix
{
  home.packages = [
    (pkgs.unstable.vivaldi.override {
      proprietaryCodecs = true;
      inherit vivaldi-ffmpeg-codecs;
    })
  ];
}
```
