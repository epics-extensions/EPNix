# EPNix documentation

:::{figure} logo.svg
:alt: EPNix logo

EPNix logo
:::

EPNix
(pronunciation: as if you are high on mushrooms)
enables you to build,
package,
deploy IOCs and other EPICS-related software
by using the [Nix] package manager.

For more information about this approach,
examine {doc}`advantages-disadvantages`.

Before getting started,
make sure to follow the {doc}`pre-requisites`.

## Features

### EPICS IOCs

The EPNix IOC framework enables you to you package,
deploy,
and test EPICS IOCs.

To get started,
read the {doc}`IOC tutorials <ioc/tutorials/index>`.

### Other packages

EPNix also packages other EPICS-related tools, such as procServ, or Phoebus.
You can build them by using Nix on any Linux distribution.

For a list of all supported EPICS-related packages, see the {doc}`pkgs/packages`.

### NixOS services

EPNix also provides NixOS modules,
which are instructions
on how to configure various EPICS-related services
on NixOS machines,
such as Archiver Appliance.

To get started,
read the {doc}`NixOS services tutorials <nixos-services/tutorials/index>`

## Release branches

EPNix has a *master* branch,
which is considered unstable,
meaning breaking changes might happen without notice.

EPNix also has release branches,
such as *{{versions.stable}}*,
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

```{toctree}
:hidden:
:titlesonly:

glossary
advantages-disadvantages
pre-requisites
cheatsheet
release-notes/index
```

```{toctree}
:caption: EPICS IOCs
:hidden:
:titlesonly:

ioc/tutorials/index
ioc/user-guides/index
ioc/explanations/index
ioc/references/options
ioc/references/packages
ioc/faq
```

```{toctree}
:caption: Packages
:hidden:
:titlesonly:

pkgs/packages
```

```{toctree}
:caption: NixOS services
:hidden:
:titlesonly:

nixos-services/tutorials/index
nixos-services/user-guides/index
nixos-services/options-reference/index
```

```{toctree}
:caption: EPNix development
:hidden:
:titlesonly:

development/guides/index
development/explanations/index
```

[Nix]: https://nixos.org/guides/how-nix-works/
[EPNix Matrix room]: https://matrix.to/#/#epnix:epics-controls.org
[EPNix repository's discussions]: https://github.com/epics-extensions/EPNix/discussions
[EPICS Tech-Talk mailing list]: https://epics.anl.gov/tech-talk/
[EPNix repository's issue tracker]: https://github.com/epics-extensions/EPNix/issues
