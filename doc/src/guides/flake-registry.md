# Setting up the flake registry

Since using EPNix epics-base isn't installed globally by default, some commonly
used command-line programs aren't available.

It is possible to go into a top, and type `nix develop` just to have `caget`
available, but it's quite tedious.

An alternative would be to run:

```bash
nix develop 'git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git'
```

This will give you the development shell of EPNix itself, with the added
benefit of having the latest version of EPICS base.

The command is quite hard to remember, but with the "registry" feature of Nix,
you can shorten it. By running:

```bash
nix registry add epnix 'git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git'
```

Referring to `epnix` in Nix command-lines will be as if you refer to the full
URL. For example, the develop command to have EPICS based installed outside of
a top would be:

```bash
nix develop epnix
```

Another benefit is that you can now initialize an EPNix top by running:

```bash
nix flake new -t epnix my-top
```
