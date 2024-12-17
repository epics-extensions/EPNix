IOC services
============

This guide covers how to install EPICS IOCs as a systemd service
on a NixOS machine.

.. include:: ./pre-requisites.rst

Exposing a service from your IOC
--------------------------------

If your EPICS top and your NixOS configuration are in two different repositories,
the recommended way to integrate your IOC is
to add the configuration inside your EPICS top repository.
This configuration will be exposed,
so that you can use it inside your NixOS configuration repository.

From your EPICS top repository,
make sure your :file:`flake.nix` has these lines:

.. code-block:: nix
   :caption: :file:`flake.nix` --- Exposed NixOS settings from your EPICS top
   :emphasize-lines: 5-12

         overlays.default = final: _prev: {
           myIoc = final.callPackage ./ioc.nix {};
         };

         nixosModules.iocService = {config, ...}: {
           services.iocs.myIoc = {
             description = "An optional description of your IOC";
             package = self.packages.x86_64-linux.default;
             # Directory where to find the 'st.cmd' file
             workingDirectory = "iocBoot/iocMyIoc";
           };
         };

Make sure ``description`` and ``workingDirectory`` are correct.
The ``workingDirectory`` must point
to the directory containing the ``st.cmd`` file to run.

If you need a file other than ``st.cmd``,
see :ref:`custom_cmd`.

.. seealso::
   For a complete list of all IOC service-related options,
   see :nix:option:`services.iocs`.

Importing the exposed service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

From your NixOS configuration repository,
in your :file:`flake.nix`,
add your EPICS top as a flake input,
and import the exposed service:

.. code-block:: nix
   :caption: :file:`flake.nix` --- Importing the IOC service from your NixOS configuration
   :emphasize-lines: 5,12,17

   {
     # ...
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     inputs.epnix.url = "github:epics-extensions/EPNix/nixos-24.11";
     inputs.myTop.url = "git+ssh://git@my-gitlab-server.com/EPICS/myTop.git";

     # ...
     outputs = {
       self,
       nixpkgs,
       epnix,
       myTop,
     }: {
       nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
         modules = [
           epnix.nixosModules.nixos
           myTop.nixosModules.iocService

           # ...
         ];
       };
     };
   }

Then apply your NixOS configuration.

Adding an external IOC
----------------------

As an alternative,
if the IOC you want to run doesn't expose a pre-configured service,
or if you don't wan't to use that configuration,
you can define it directly in your NixOS configuration.

From your NixOS configuration repository,
add your EPICS top to your flake inputs and overlays.
For example:

.. code-block:: nix
   :caption: :file:`flake.nix` --- Adding your top to your flake inputs and overlays
   :emphasize-lines: 5,12,19-28

   {
     # ...
     inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     inputs.epnix.url = "github:epics-extensions/EPNix/nixos-24.11";
     inputs.myTop.url = "git+ssh://git@my-gitlab-server.com/EPICS/myTop.git";

     # ...
     outputs = {
       self,
       nixpkgs,
       epnix,
       myTop,
     }: {
       nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
         modules = [
           epnix.nixosModules.nixos
           # ...

           {
             nixpkgs.overlays = [
               (final: prev: {
                 # Add 'myTop' to the set of 'pkgs'
                 myTop = myTop.packages.x86_64-linux.default;
                 # Add your other tops here, for example:
                 #myOtherTop = myOtherTop.packages.x86_64-linux.default;
               })
             ];
           }
         ];
       };
     };
   }

Then create an :file:`{myIoc}.nix` file:

.. code-block:: nix
   :caption: :file:`{myIoc}.nix` --- IOC configuration example

   { pkgs, ... }:
   {
     # Replace 'myIoc' below with the name of your IOC
     services.iocs.myIoc = {
       description = "An optional description of your IOC";
       package = pkgs.myTop;
       # Directory where to find the 'st.cmd' file
       workingDirectory = "iocBoot/iocMyIoc";
     };
   }

Make sure to import it in your :file:`flake.nix`.

.. seealso::
   For a list of all IOC-related options,
   see :nix:option:`services.iocs`.

.. _custom_cmd:

Custom cmd file
---------------

If your IOC is started through a script other than a file :file:`st.cmd`,
set the option :nix:option:`services.iocs.<name>.startupScript` to you cmd script.

Custom procServ options
-----------------------

To change the procServ port,
use :nix:option:`services.iocs.<name>.procServ.port`.

To change or add procServ options,
use :nix:option:`services.iocs.<name>.procServ.options`.

For example:

.. code-block:: nix
   :caption: Changing the default ``procServ`` options

     services.iocs.myIoc = {
       package = pkgs.myTop;
       # Directory where to find the 'st.cmd' file
       workingDirectory = "iocBoot/iocMyIoc";

       procServ = {
         # Set the port procServ listens to
         port = 2001;
         # Add an option `--killcmd "^b"`
         options.killcmd = "^b";
       };
     };

Passing environment variables
-----------------------------

You can set environment variables for your IOC
by using the option :nix:option:`services.iocs.<name>.environment`.
For example:

.. code-block:: nix
   :caption: Setting environment variables
   :emphasize-lines: 5

     services.iocs.myIoc = {
       package = pkgs.myTop;
       workingDirectory = "iocBoot/iocMyIoc";

       environment.EPICS_CA_MAX_ARRAY_BYTES = 10000;
     };

Adding programs to the PATH
---------------------------

If your IOC calls external programs,
you need to add those programs to your IOC's PATH.

To do this,
use the option :nix:option:`services.iocs.<name>.path`.
For example:

.. code-block:: nix
   :caption: Adding programs to the IOC's PATH
   :emphasize-lines: 1,7

   {pkgs, ...}:
   {
     services.iocs.myIoc = {
       package = pkgs.myTop;
       workingDirectory = "iocBoot/iocMyIoc";

       path = [pkgs.pciutils];
     };
   }

.. tip::

   Programs installed via the ``environment.systemPackages`` option are *not* available
   to systemd services.

Further customization
---------------------

For other customization of IOC services,
you can edit the generated systemd service
by setting the options under :samp:`systemd.services.{myIoc}`.

For example,
to make your machine reboot
if your IOC fails to start:

.. code-block:: nix
   :caption: Customizing the IOC systemd service

     services.iocs.myIoc = {
       package = pkgs.myTop;
       workingDirectory = "iocBoot/iocMyIoc";
     };

     # These options will modify the generated systemd service
     systemd.services.myIoc = {
       # These options will modify the [Unit] section
       # See `man systemd.unit` for available options in this section
       unitConfig = {
         # If the IOC reboot 5 times
         StartLimitBurst = 5;
         # in 30 seconds
         StartLimitIntervalSec = 30;
         # reboot
         StartLimitAction = "reboot";
       };
     };

For more information,
examine the `systemd.services options`_,
and the man pages :manpage:`systemd.unit(5)`,
:manpage:`systemd.service(5)`,
and other related systemd documentation.

.. _systemd.services options: https://search.nixos.org/options?query=systemd.services.
