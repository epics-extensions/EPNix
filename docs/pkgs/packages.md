# Packages list

## General packages

```{nix:autopackages} epnix
:no-recursive:
```

(epics-support-module-list)=
## EPICS support modules

These packages are meant to be used in an EPICS IOC.

```{nix:autopackages} epnix.support
```

## Phoebus ecosystem VMs

Images for running the Phoebus ecosystem inside a VM.
See the {doc}`user-guides/phoebus-ecosystem-vm` guide
for more information.

```{nix:autopackages} epnix.phoebus-ecosystem
```

## Python modules

These packages are available under `pkgs.python3Packages`
or under {samp}`pkgs.python3{XX}Packages`
where _XX_ is the Python minor version,
for example `pkgs.python313Packages`.

```{nix:autopackages} python3Packages
```

## Linux kernel modules

These packages are available under `pkgs.linuxPackages`
or under {samp}`pkgs.linuxKernel.packages.linux_{XX}`
where _XX_ is a variant of the Linux kernel.

In most cases,
kernel modules are added under NixOS
by using the `boot.extraModulePackages` option.

```{nix:autopackages} linuxPackages
```

## CI scripts

These packages are used by the EPNix CI.
Make sure to read their source code
before running them locally.

These packages are internal to EPNix
and have no stability guarantees.

```{nix:autopackages} epnix.ci-scripts
```
