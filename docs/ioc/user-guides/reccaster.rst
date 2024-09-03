RecCaster configuration
=======================

RecCaster is an EPICS support module
that sends PV names and IOC metadata to a "RecCeiver" server.
This setup is often used to send such metadata to a ChannelFinder database.

.. seealso::

   If you want to set up a RecCeiver and ChannelFinder server,
   examine the guide
   :doc:`../../nixos-services/user-guides/channel-finder`.

Configuration
-------------

To configure RecCaster,
first add it to your build environment:

.. code-block:: diff
   :caption: :file:`flake.nix`

            # Add your support modules here:
            # ---
   -        #support.modules = with pkgs.epnix.support; [ StreamDevice mySupportModule ];
   +        support.modules = with pkgs.epnix.support; [ reccaster ];

Make sure your app depends on the RecCaster library and DBD file:

.. code-block:: make
   :caption: :file:`{example}App/src/Makefile`

   # Replace "example" by the name of your application
   example_DBD += reccaster.dbd
   example_LIBS += reccaster

And load the RecCaster database:

.. code-block:: csh
   :caption: :file:`iocBoot/ioc{Example}/st.cmd`

   ## Load RecCaster records
   ## Optional but useful for checking the synchronization state
   ## Make sure to choose your prefix by setting the 'P' macro
   dbLoadRecords("${RECCASTER}/db/reccaster.db", "P=YOUR-PV-PREFIX:")

This configuration is enough to start the RecCaster client.

.. note::

   RecCaster doesn't need the address of the RecCeiver server.
   The RecCeiver server scans for available IOCs on the network.

Firewall
--------

To accept connection from the RecCeiver service,
the firewall needs to allow the UDP announcert port,
which by default is 5049.

If your IOC is a NixOS machine,
you can open the firewall with this NixOS configuration:

.. code-block:: nix
   :caption: Opening the firewall for RecCeiver

   networking.firewall.allowedUDPPorts = [5049];

Checking synchronization status
-------------------------------

To check the RecCaster status of your IOC,
you can run:

.. code-block:: bash

   # Replace 'YOUR-PV-PREFIX:' with your PV prefix
   caget "YOUR-PV-PREFIX:Msg-I"
   caget "YOUR-PV-PREFIX:State-Sts"

Adding IOC metadata
-------------------

You can choose to send more information to the RecCeiver server.

If you want to add metadata about the global IOC,
set it as environment variable
and expose it using the ``addReccasterEnvVars`` function.
For example:

.. code-block:: csh
   :caption: :file:`iocBoot/ioc{Example}/st.cmd`

   epicsEnvSet("CONTACT", "mycontact")
   addReccasterEnvVars("CONTACT")

Make sure RecCeveiver forward those variables to ChannelFinder.
See the RecCeiver guide's :ref:`recceiver-custom-metadata`.

For more information about what information RecCaster sends to the server,
examine the `RecSync README`_.

.. tip::

   RecCaster automatically sends some environment variables to RecCeiver,
   without needing to call ``addReccasterEnvVars``,
   for example:

   - PWD
   - EPICS_VERSION
   - EPICS_HOST_ARCH
   - IOCNAME
   - HOSTNAME
   - ENGINEER
   - LOCATION

   But those variables aren't automatically forwarded to ChannelFinder.
   For how to forward them to ChannelFinder,
   examine the RecCeiver guide's :ref:`recceiver-custom-metadata`.

.. _RecSync README: https://github.com/ChannelFinder/recsync?tab=readme-ov-file#information-uploaded
