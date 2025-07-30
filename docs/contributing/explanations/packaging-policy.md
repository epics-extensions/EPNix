# Packaging policy

In its package repository,
EPNix officially supports the latest upstream version.

But,
since EPNix is a Git repository,
users are able to use a fixed version of EPNix,
without being forced to upgrade your dependencies.

## Upstream what's possible

When packaging software in EPNix,
the goal is to package the upstream software unchanged,
as much as possible.

If there is a build issue,
or a missing feature,
prefer talking to the maintainers
of the upstream package,
to see if it can be resolved in the upstream repository.

## Be simple

When writing Nix code,
try to write it in a way that's the most common
in the ecosystem.

For example,
when packaging Python software,
use the functions provided by Nixpkgs,
such as `buildPythonPackage` or `buildPythonApplication`.

## Write documentation

For each use case a user might have with your package or NixOS module,
write a guide in the documentation.

See the documentation philosophy explanation (TODO).

## Write tests

For each package and NixOS module you're adding to the EPNix repository,
try to add tests where possible.

It can be:

-   running the tests of the package itself
    -   for example,
        by running `pytest` in a Python package
-   using [package tests]
    -   meaning,
        packages that fail to build if a test fail
-   using [NixOS tests]

## Backport changes

When a change is non-breaking,
for example upgrading a minor version of a given package,
backport the changes to latest stable release of EPNix.

  [package tests]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#package-tests
  [NixOS tests]: https://nixos.org/manual/nixos/stable/#sec-nixos-tests
