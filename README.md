# EPNix

![](./docs/logo.svg)

EPNix (pronunciation: like you are high on mushrooms) packages EPICS-related software by using the [Nix] package manager.

It's made of three parts:

-   the EPICS IOC framework
-   other EPICS-related packages
-   NixOS modules

The EPICS IOC framework lets you package, deploy, and test EPICS IOCs by using the Nix package manager, which provides several benefits.
For more information, see the [EPICS IOC documentation].

EPNix also packages other EPICS-related tools, such as procServ, Phoebus, and so on.
You can build them by using Nix, while having a strong guarantee that they work as-is.
For a list of all supported EPICS-related packages, see the [Packages list].

Note: providing a cache server that enables you to download dependencies pre-compiled is anticipated.

EPNix also provides NixOS modules, which are instructions on how to configure various EPICS-related services on NixOS machines (for example the Phoebus alarm server).
EPNix strives to have integration tests for each of those module.
For more information, see the [NixOS services documentation].

  [Nix]: https://nixos.org/guides/how-nix-works.html
  [EPICS IOC documentation]: https://epics-extensions.github.io/EPNix/ioc/
  [Packages list]: https://epics-extensions.github.io/EPNix/pkgs/packages.html
  [NixOS services documentation]: https://epics-extensions.github.io/EPNix/nixos-services/

## Getting started building IOCs

See [over there] in the documentation book.

  [over there]: https://epics-extensions.github.io/EPNix/

## Packaging policy

In its package repository, EPNix officially supports the latest upstream version.

This doesn't cause much issues: since EPNix is a Git repository, you use a fixed version of EPNix, without being forced to upgrade your dependencies.

### The epics-base package

The epics-base package has no significant modification compared to the upstream version on [GitHub].
One goal of EPNix is to have as little modification as possible, and upstream what's possible.

  [GitHub]: https://github.com/epics-base/epics-base/
