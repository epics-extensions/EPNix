---
title: EPNix documentation
---

![](./logo.svg){width=70% fig-align=center}

# Introduction

EPNix (pronunciation: like you are high on mushrooms) packages EPICS-related
software using the [Nix](https://nixos.org/guides/how-nix-works.html) package manager.

It's made of three parts:

- the EPICS IOC framework
- other EPICS-related packages
- NixOS modules

The EPICS IOC framework lets you package, deploy, and test EPICS IOCs
using the Nix package manager, which provides several benefits. For more
information, see the [EPICS IOCs introduction](./ioc/introduction.md).

EPNix also packages other EPICS-related tools, like procServ, Phoebus, etc.
You can build them using Nix, and in the future download them pre-compiled,
while having a strong guarantee that they will work as-is. For a list of all
supported EPICS-related packages, see the [Packages list](./pkgs/packages.md).

EPNix also provides NixOS modules, which are instructions on how to configure
various EPICS-related services on NixOS machines (for example the Phoebus alarm
server). EPNix strives to have integration tests for each of those module. For
more information, see the [NixOS modules
introduction](./nixos/introduction.md).

# Packaging policy

As EPNix provides a package repository, packaging for example `epics-base`, `asyn`,
`StreamDevice`, `procServ`, `phoebus`, etc., it needs to have a packaging
policy.

In its package repository, EPNix officially supports the latest upstream
version.

However, since EPNix is a git repository, you will be able, through Nix, to use
a fixed version of EPNix, without being forced to upgrade your dependencies.

<!-- TODO: link to an explanation, from the IOC side, and from the NixOS side -->

## The epics-base package

The epics-base package has no significant modification compared to the upstream
version at [Launchpad](https://git.launchpad.net/epics-base). One goal of EPNix is to keep those
modifications to a minimum, and upstream what's possible.

---

This documentation follows the [Diátaxis](https://diataxis.fr/) documentation
framework.
