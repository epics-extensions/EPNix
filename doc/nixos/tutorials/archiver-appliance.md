---
title: Creating an Archiver Appliance instance
---

In this tutorial,
we're going to see how to create a virtual machine that runs Archiver Appliance,
under the NixOS Linux distribution.

Installing Archiver Appliance on a physical machine is definitely possible,
but this tutorial focuses on virtual machines for simplicity's sake.

You will need:

-   A virtual machine,
-   and the [NixOS ISO file].
    Select the "Graphical ISO image."

  [NixOS ISO file]: https://nixos.org/download#download-nixos

# Installing NixOS

First things first,
create your virtual machine,
and select the ISO image that you downloaded.

Then, start the virtual machine.

From the booted virtual machine,
you can follow the graphical installation process,
and reboot once finished.

You can select any desktop environment,
or no desktop.
This tutorial only uses the command-line.

# Making your configuration a flake

The installation process created the `/etc/nixos` directory in your VM.
This directory describes the complete configuration of your machine.

EPNix is a "Nix flake",
which a way of managing Nix projects.
Using Nix flakes also enables you to use Nix code outside of your repository,
in a controlled manner.
For more information,
see the [Nix flake command manual] and the [Flake wiki page].

To be able to import EPNix into you NixOS configuration,
you first need to turn your NixOS configuration into a Nix flake.

As root, place yourself in the `/etc/nixos` directory in your virtual machine.
Create a `flake.nix` file under it,
by running `nano flake.nix`.
Fill the file with these lines:

``` {.nix filename="flake.nix" code-line-numbers="true"}
{
  description = "Configuration for running Archiver Appliance in a VM";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.epnix.url = "github:epics-extensions/EPNix";

  outputs = { self, nixpkgs, epnix }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        epnix.nixosModules.nixos

        ./configuration.nix
      ];
    };
  };
}
```

Save and quit by typing {{< kbd Ctrl-x >}}, {{< kbd y >}}, and {{< kbd Enter >}},
and run `nixos-rebuild test` to test your changes.

Some explanations:

You can see in the `flake.nix` file that the flake has 2 inputs:
`nixpkgs` and `epnix`,
lines 4--5.

Having the `nixpkgs` input enables you to use code from [Nixpkgs].
This is what enables you to use all those NixOS options,
and every package installed on your machine now.
For more information,
you can read the [Nixpkgs preface]
With the current configuration,
we are only using code from Nixpkgs.

Having the `epnix` input is what's going to enable you to use [packages from EPNix],
such as Archiver Appliance.
It also enables you to use [EPNix' extra NixOS options],
such as the options configuring Tomcat, the systemd service, the `archappl` user and group, MariaDB, and so on.

  [Nix flake command manual]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html
  [Flake wiki page]: https://nixos.wiki/wiki/Flakes
  [Nixpkgs]: https://github.com/NixOS/nixpkgs
  [Nixpkgs preface]: https://nixos.org/manual/nixpkgs/stable/#preface
  [packages from EPNix]: ../../pkgs/packages.md
  [EPNix' extra NixOS options]: ../options.md

# Configuring Archiver Appliance

Now for the fun part,
actually using those EPNix options to install and configure Archiver Appliance,
and all its dependencies.

Create and edit the file `archiver-appliance.nix` under `/etc/nixos`.
For now, here are the contents:

``` {.nix filename="archiver-appliance.nix"}
{
  services.archiver-appliance.enable = true;
}
```

In your `flake.nix`,
import the newly created file by adding `./archiver-appliance.nix`,
under `./configuration.nix`:

``` diff
       modules = [
         epnix.nixosModules.nixos

         ./configuration.nix
+        ./archiver-appliance.nix
       ];
```

If you try to test your changes by running `nixos-rebuild test`,
you will see a helpful error message:

::: sourceCode
``` sourcecode
error: The option `services.archiver-appliance.stores.lts.location'
  is used but not defined.
(use '--show-trace' to show detailed location information)
```
:::

This tells you that the `services.archiver-appliance.stores.lts.location` is mandatory,
but we didn't set any value.

To figure out what this option is about,
you can examine the [options reference].

The options reference gives a description for this option:

> Backing directory containing the LTS.

and an example:

``` nix
"/data/lts"
```

It tells us that you need to choose where the Long Term Store (LTS) is.
See the "Architecture" section of the [Archiver Appliance Details] page for what the various stores are.

Because this is a test VM,
let's configure the LTS to a test location,
like `/tmp/lts`.
You will also need to configure the location of the Medium Term Store (MTS).

Here's how to change `archiver-appliance.nix`:

``` {.nix filename="archiver-appliance.nix"}
{
  services.archiver-appliance.enable = true;
  services.archiver-appliance.stores.lts.location = "/tmp/lts";
  services.archiver-appliance.stores.mts.location = "/tmp/mts";
}
```

If you don't want to repeat yourself,
you can also change it like so:

``` {.nix filename="archiver-appliance.nix"}
{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/tmp/lts";
    stores.mts.location = "/tmp/mts";
  };
}
```

And now,
`nixos-rebuild test` should succeed:

::: sourceCode
``` sourcecode
building the system configuration...
activating the configuration...
setting up /etc...
reloading user units for admin...
setting up tmpfiles
reloading the following units: dbus.service
the following new units were started: arch-lts-ArchiverStore.mount,
  arch-mts-ArchiverStore.mount, arch-sts-ArchiverStore.mount,
  mysql.service, tomcat.service
```
:::

From the message,
we can guess it started the Tomcat server running Archiver Appliance,
the MySQL (in fact, MariaDB) server,
and mounted some partitions.
Fantastic!

You can run the `systemctl list-units` command to see if any systemd unit failed.

In the default configuration,
Archiver Appliance and Tomcat are configured to output logs to journald.
You can see those logs by running:

``` bash
journalctl -xeu tomcat.service
```

You can also see the MariaDB logs by running:

``` bash
journalctl -xeu mysql.service
```

::: callout-note
Here are some details on what was done by EPNix' `services.archiver-appliance` NixOS module:

-   Creation of the Linux user and group `archappl`
-   Installation and configuration of MariaDB:
    -   Creation of the `archappl` user,
        with UNIX socket authentication
    -   Creation of the Archiver Appliance database
    -   Creation of the [various tables] in that database
    -   Giving access rights to this database for the `archappl` user
-   Installation and configuration of Tomcat:
    -   Installation of the WAR files of Archiver Appliance
    -   Installation of the MariaDB connector and its dependencies
    -   Configuring the MariaDB connector to authenticate to the database
    -   Logging configuration to `journald`
-   Configuring mounts so that:
    -   `/arch/lts` and `/arch/mts` are bind mounts to the configured locations,
        with some added security options,
        such as `nodev` and `noexec`
    -   Mounting `/arch/sts` as a new `tmpfs`
:::

Tomcat runs by default under port 8080,
and NixOS has a firewall enabled by default.

Change your `archiver-appliance.nix`:

``` {.nix filename="archiver-appliance.nix"}
{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/tmp/lts";
    stores.mts.location = "/tmp/mts";

    # New option:
    openFirewall = true;
  };
}
```

and run `nixos-rebuild test`.
It will restart `firewall.service`,
but configured to allow incoming connection on port 8080.

Check the IP address of your VM with `ip a`,
and open a browser to `http://<YOUR_VM_IP>:8080/mgmt/ui/index.html`.

Finally,
run `nixos-rebuild switch` to confirm your changes.
This will apply your changes for the next reboot,
by adding a new boot entry,
enabling you to go back to a previous configuration.

You have now configured Archiver Appliance on NixOS.

  [options reference]: ../options.md
  [Archiver Appliance Details]: https://slacmshankar.github.io/epicsarchiver_docs/details.html
  [various tables]: https://github.com/slacmshankar/epicsarchiverap/blob/master/src/main/org/epics/archiverappliance/config/persistence/archappl_mysql.sql

# Next steps

This VM configuration has some problems:

-   It stores the LTS and MTS in `/tmp`,
    which by default is cleaned on reboot
-   The size of the Short Term Store (STS) isn't configured
-   Both "management" and "retrieval" URLs are accessible without authentication

The following sections are some pointers to fix these issues.

## Configuring partitions

If you want to change the location of the LST or MTS,
you can change the value of the corresponding options:

-   `services.archiver-appliance.stores.lts.location`
-   `services.archiver-appliance.stores.mts.location`

But these values won't mean much if the configured directories are not backed by the appropriate hardware.

As an example given by the [Archiver Appliance Details] page,
section "Architecture",
we can have the LTS backed by a NAS or SAN,
and the MTS backed by SSD or SAS storage.

The way to do that is to configure the `fileSystems` NixOS option.
See the [File Systems NixOS documentation] for more information.

  [Archiver Appliance Details]: https://slacmshankar.github.io/epicsarchiver_docs/details.html
  [File Systems NixOS documentation]: https://nixos.org/manual/nixos/stable/#ch-file-systems

## Size of the short term store

To configure the size of the short term store,
use the `services.archiver-appliance.stores.sts.size` option.

For example:

``` {.nix filename="archiver-appliance.nix"}
{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/tmp/lts";
    stores.mts.location = "/tmp/mts";

    openFirewall = true;

    # New option:
    stores.sts.size = "20g";
  };
}
```

See the [`sts.size` option] in the reference for a more in-depth description.

  [`sts.size` option]: ../options.md#services.archiver-appliance.stores.sts.size

## Restricting access

Allowing access to `mgmt` URLs to anyone can be dangerous,
because it allows anyone to delete and archive PVs.

To restrict access,
you can close the firewall and put an nginx server in front.

You can configure the nginx server to disallow access to the URLs you want.
You can also configure nginx to require authentication.

```{=html}
<!-- TODO: make a guide including HTTPS setup -->
```
