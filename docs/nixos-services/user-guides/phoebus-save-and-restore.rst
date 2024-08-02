Phoebus Save-and-restore setup
==============================

The Phoebus Save-and-restore service is used by clients
to manage configuration and snapshots of PV values.
These snapshots can then be used by clients for comparison or for restoring PVs.

This guide focuses on installing and configuring the Save-and-Restore service on a single server.

For more details and documentation about Phoebus Save-and-Restore,
you can examine the `Save-and-restore official documentation`_.

.. include:: ./pre-requisites.rst

.. _Save-and-restore official documentation: https://control-system-studio.readthedocs.io/en/latest/services/save-and-restore/doc/index.html

Enabling the Phoebus Save-and-restore service
---------------------------------------------

To enable the Phoebus Save-and-restore service,
add this to your configuration:

.. code-block:: nix
   :caption: :file:`phoebus-save-and-restore.nix`

   {lib, ...}: {
     services.phoebus-save-and-restore = {
       enable = true;
       openFirewall = true;
     };

     # Phoebus save-and-restore needs ElasticSearch.
     # If not already enabled elsewhere in your configuration,
     # Enable it with the code below:
     services.elasticsearch = {
       enable = true;
       package = pkgs.elasticsearch7;
     };

     # Elasticsearch, needed by Phoebus Save-and-restore, is not free software (SSPL | Elastic License).
     # To accept the license, add the code below:
     nixpkgs.config.allowUnfreePredicate = pkg:
       builtins.elem (lib.getName pkg) [
         "elasticsearch"
       ];
   }

From the Phoebus graphical client side,
add this configuration

.. code-block:: ini
   :caption: :file:`phoebus-client-settings.ini`

   # Replace the IP address with your server's IP address or domain name
   org.phoebus.applications.saveandrestore/jmasar.service.url=http://192.168.1.42:8080

.. warning::

   URLs for future versions of Phoebus Save-and-restore will need to change to:
   ``http://192.168.1.42:8080/save-restore``
