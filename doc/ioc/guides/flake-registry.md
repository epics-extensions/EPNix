---
title: Setting up the flake registry
---

Since the usage of EPNix doesn't encourage installing epics-base globally, some commonly used command-line programs won't be available in your usual environment.

It's possible to go into a top, and type `nix develop`{.bash} just to have the `caget`{.bash} command available, but it's quite tedious.

An alternative would be to run:

``` bash
nix develop 'github:epics-extensions/epnix'
```

This will give you the development shell of EPNix itself, with the added benefit of having the latest version of EPICS base.

The command is quite hard to remember, but with the "registry" feature of Nix, you can shorten it by running:

``` bash
nix registry add epnix 'github:epics-extensions/epnix'
```

Now, referring to `epnix` in Nix command-lines will be as if you referred to the full URL.
For example, the develop command to have EPICS based installed outside of a top would be:

``` bash
nix develop epnix
```

Another benefit is that you can now initialize an EPNix top by running:

``` bash
nix flake new -t epnix my-top
```
