# EPNix

![](./docs/logo.svg)

[Documentation]

EPNix
(pronunciation: as if you are high on mushrooms)
enables you to build,
package,
deploy IOCs and other EPICS-related software
by using the [Nix] package manager.

Before getting started,
make sure to follow the [Pre-requisites].

## Features

### EPICS IOCs

The EPNix IOC framework enables you to you package,
deploy,
and test EPICS IOCs.

To get started,
read the [IOC tutorials].

### Other packages

EPNix also packages other EPICS-related tools, such as procServ, or Phoebus.
You can build them by using Nix on any Linux distribution.

For a list of all supported EPICS-related packages, see the [Packages list].

### NixOS services

EPNix also provides NixOS modules,
which are instructions
on how to configure various EPICS-related services
on NixOS machines,
such as Archiver Appliance.

To get started,
read the [NixOS services tutorials].

## Release branches

EPNix has a `master` branch,
which is considered unstable,
meaning breaking changes might happen without notice.

EPNix also has release branches,
such as `nixos-24.11`,
tied to the nixpkgs release branches,
where breaking changes are forbidden.

Backporting changes to older release branches is done on a "best-effort" basis.

## Getting help

You can get help by:

-   asking questions in:
    -   the [EPNix Matrix room]
    -   the [EPNix repository's discussions]
    -   the [EPICS Tech-Talk mailing list]
-   reporting issues in the [EPNix repository's issue tracker]

## How to contribute

To contribute to the EPNix repository,
see the "EPNix development" documentation section.

## License

EPNix is under the MIT license.

[Documentation]: https://epics-extensions.github.io/EPNix/
[EPICS Tech-Talk mailing list]: https://epics.anl.gov/tech-talk/
[EPNix Matrix room]: https://matrix.to/#/#epnix:epics-controls.org
[EPNix repository's discussions]: https://github.com/epics-extensions/EPNix/discussions
[EPNix repository's issue tracker]: https://github.com/epics-extensions/EPNix/issues
[IOC tutorials]: https://epics-extensions.github.io/EPNix/dev/ioc/tutorials/index.html
[NixOS services tutorials]: https://epics-extensions.github.io/EPNix/dev/nixos-services/tutorials/index.html
[Nix]: https://nixos.org/guides/how-nix-works/
[Packages list]: https://epics-extensions.github.io/EPNix/dev/pkgs/packages.html
[Pre-requisites]: https://epics-extensions.github.io/EPNix/dev/pre-requisites.html
