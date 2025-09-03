# Prerequisites

## Global prerequisites

Make sure to follow EPNix' global {doc}`../../prerequisites`.

## NixOS flake

One prerequisite is having a NixOS machine with a flake configuration.

If you’re not sure how to do this,
you can follow the {doc}`../tutorials/archiver-appliance` tutorial,
which is a good introduction on how to make a NixOS VM.

If you have such a configuration,
make sure that:

- You have the `epnix` flake input
- You have added `epnix` as an argument to your flake outputs
- You have imported EPNix’ NixOS module

For example:

```{code-block} diff
:caption: {file}`flake.nix`

 {
   # ...
   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
+  inputs.epnix.url = "github:epics-extensions/EPNix/nixos-25.05";

   # ...
   outputs = {
     self,
     nixpkgs,
+    epnix,
   }: {
     nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
       modules = [
+        epnix.nixosModules.nixos

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
