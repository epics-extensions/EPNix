# Prerequisites

## Global prerequisites

Make sure to follow EPNix's global {doc}`../../prerequisites`.

## NixOS configuration flake

Make sure your NixOS configuration is a Nix flake.

If you're not sure how to do this,
you can follow the {doc}`../tutorials/archiver-appliance` tutorial,
which provides a good introduction on creating a NixOS VM.

## Importing the EPNix NixOS module

If you have such a configuration,
make sure that:

- You have the `epnix` flake input
- You have added `epnix` as an argument to your flake outputs
- You have imported EPNix's NixOS module

```{code-block} nix
:caption: {file}`flake.nix` --- Importing the EPNix NixOS module
:emphasize-lines: 4,10,14

{
  # ...
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  inputs.epnix.url = "github:epics-extensions/EPNix/nixos-25.11";

  # ...
  outputs = {
    self,
    nixpkgs,
    epnix,
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        epnix.nixosModules.nixos

        # ...
      ];
    };
  };
}
```

## Hostname consistency

In your {file}`flake.nix`,
you should see the line {samp}`nixosConfigurations.{hostname} = ...`.

Make sure the specified _hostname_ is consistent
with the machine's hostname,
which is defined by the option `networking.hostName`.

## Installing the `nixos-rebuild` utility

To rebuild a NixOS configuration,
you need the `nixos-rebuild` command.

:::{tip}
If you're rebuilding the configuration locally on the NixOS system,
the command is already provided.
:::

If you're rebuilding a NixOS configuration remotely,
for example on a developer machine,
you can install it by running:

```{code-block} bash
:caption: Installing the `nixos-rebuild` utility

nix-env -iA nixpkgs.nixos-rebuild
```
