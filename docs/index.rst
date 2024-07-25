EPNix documentation
===================

.. figure:: logo.svg
   :alt: EPNix logo

   EPNix logo

Introduction
------------

EPNix (pronunciation: like you are high on mushrooms) packages EPICS-related software using the `Nix`_ package manager.

It’s made of three parts:

-  the EPICS IOC framework
-  other EPICS-related packages
-  NixOS modules

The EPICS IOC framework lets you package, deploy, and test EPICS IOCs
using the Nix package manager, which provides several benefits.
For more information, see the :doc:`EPICS IOCs introduction <ioc/index>`.

EPNix also packages other EPICS-related tools, like procServ, Phoebus, etc.
You can build them using Nix, and in the future download them pre-compiled, while having a strong guarantee that they will work as-is.
For a list of all supported EPICS-related packages, see the :doc:`pkgs/packages`.

EPNix also provides NixOS modules, which are instructions on how to configure various EPICS-related services on NixOS machines (for example the Phoebus alarm server).
EPNix strives to have integration tests for each of those modules.
For more information, see the :doc:`NixOS services introduction <nixos-services/index>`.

.. _Nix: https://nixos.org/guides/how-nix-works/

Packaging policy
~~~~~~~~~~~~~~~~

As EPNix provides a package repository, packaging for example ``epics-base``, ``asyn``, ``StreamDevice``, ``procServ``, ``phoebus``, etc., it needs to have a packaging policy.

In its package repository, EPNix officially supports the latest upstream version.

However, since EPNix is a git repository, you will be able, through Nix, to use a fixed version of EPNix, without being forced to upgrade your dependencies.

.. TODO: link to an explanation, from the IOC side, and from the NixOS side

The epics-base package
^^^^^^^^^^^^^^^^^^^^^^

The epics-base package has no significant modification compared to the upstream version at `Launchpad`_.
One goal of EPNix is to keep those modifications to a minimum, and upstream what’s possible.

.. _Launchpad: https://git.launchpad.net/epics-base

Release branches
~~~~~~~~~~~~~~~~

EPNix has a ``master`` branch,
which is considered unstable,
meaning breaking changes might happen without notice.

EPNix also has release branches,
such as ``nixos-23.11``,
tied to the nixpkgs release branches,
where breaking changes are forbidden.

Backporting changes to older release branches is done on a “best-effort” basis.

--------------

This documentation follows the `Diátaxis`_ documentation framework.

.. _Diátaxis: https://diataxis.fr/

.. toctree::
   :caption: EPICS IOCs
   :hidden:
   :titlesonly:

   ioc/index
   ioc/tutorials/index
   ioc/user-guides/index
   ioc/references/options
   ioc/references/packages
   ioc/faq

.. toctree::
   :caption: Packages
   :hidden:
   :titlesonly:

   pkgs/packages

.. toctree::
   :caption: NixOS services
   :hidden:
   :titlesonly:

   nixos-services/index
   nixos-services/tutorials/index
   nixos-services/user-guides/index
   nixos-services/options


.. TODO: link an index to Nix options and packages
