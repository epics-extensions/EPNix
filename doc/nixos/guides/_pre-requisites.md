# Pre-requisites

-   Having a NixOS machine with a flake configuration.

If you're not sure how to do this,
you can follow the [Archiver Appliance tutorial],
which is a good introduction on how to make a NixOS VM.

If you have such a configuration,
make sure that:

-   You have the `epnix` flake input
-   You have added `epnix` as an argument to your flake outputs
-   You have imported EPNix' NixOS module

For example:

``` {.diff filename="flake.nix"}
 {
   # ...
+  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

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

  [Archiver Appliance tutorial]: ../tutorials/archiver-appliance.md
