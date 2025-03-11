Micro Research Finland timing devices
=====================================

To control Micro Research Finland (MRF) devices,
we recommend using the :ref:`pkg-support.mrfioc2` EPICS module.

Installing the ``mrfioc2`` EPICS support module
-----------------------------------------------

To use the ``mrfioc2`` module in your EPNix IOC,
make sure to add the :ref:`pkg-support.mrfioc2` package in your support modules:

.. code-block:: nix
   :caption: :file:`ioc.nix` --- Add the mrfioc2 support module to the build environment

   propagatedBuildInputs = [
     epnix.support.mrfioc2
   ];

This makes sure that the ``mrfioc2`` is available during compilation.

For developing your IOC using ``mrfioc2``,
follow the `mrfioc2 documentation`_.

.. _mrfioc2 documentation: https://epics-modules.github.io/mrfioc2/

Installing the ``mrf`` kernel module
------------------------------------

To communicate with the MRF devices,
you also need to install and load the ``mrf`` kernel module.

If you are using NixOS,
add this to the NixOS configuration of the board running the IOC:

.. code-block:: nix
   :caption: :file:`mrf.nix`

   { config, ... }:
   {
     # Install the MRF kernel module package
     boot.extraModulePackages = with config.boot.kernelPackages; [ mrf ];
     # Load the "mrf" module at boot
     boot.kernelModules = [ "mrf" ];
   }
