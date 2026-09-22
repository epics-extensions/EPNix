# SoftIOC services

This guide covers how to install EPICS SoftIOCs as a systemd service
on a NixOS machine.

SoftIOCs don't depend on any EPICS support module,
and are generally described by their database content only.

:::{tip}
Contrary to {doc}`ioc-services`,
this module is for deploying "soft" IOCs
that don't depend on any EPICS support module.
:::

:::{seealso}
For a complete list of all IOC service-related options,
see {nix:option}`services.softIocs`.
:::

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

## Create a service

To create a service,
set any option inside {nix:option}`services.softIocs.<name>.`
For example,
to run an empty SoftIOC without any PV,
set:

```{code-block} nix
:caption: `softioc.nix` --- Creating a SoftIOC named `mySoftIoc`

{
  services.softIocs.mySoftIOC.dbText = "";
}
```

## Set a description

To set a description for your IOC,
use the {nix:option}`~services.softIocs.<name>.description` option.
This description is used in the systemd service
and will be shown in systemd logs.

```{code-block} nix
:caption: `softioc.nix` --- Setting a description

{
  services.softIocs.mySoftIOC = {
    description = "My super documented IOC";
    # ...
  };
}
```

## Specify the database

### Inline

To specify the content of the EPICS database as a string
in the NixOS configuration,
use the {nix:option}`~services.softIocs.<name>.dbText` option:

```{code-block} nix
:caption: `softioc.nix` --- Creating a SoftIOC named `mySoftIoc`

{
  services.softIocs.mySoftIOC.dbText = ''
    record(ai, MY_PV) {
      # ...
    }

    # ...
  '';
}
```

### As a separate file

To specify the content of the EPICS database as a separate file,
use the {nix:option}`~services.softIocs.<name>.dbFiles` option:

```{code-block} nix
:caption: `softioc.nix` --- Creating a SoftIOC named `mySoftIoc`

{
  services.softIocs.mySoftIOC.dbFiles = [ ./mySoftIOC.db ];
}
```

## Enable pvAccess

To make your SoftIOC expose PVs in both Channel Access and pvAccess,
through PVXS' QSRV2 mechanism,
use the {nix:option}`services.softIocs.<name>.pvAccess.enable` option:

```{code-block} nix
:caption: `softioc.nix` --- Creating a pvAccess SoftIOC

{
  services.softIocs.mySoftIOC = {
    dbFiles = [ ./mySoftIOC.db ];
    pvAccess.enable = true;
  };
}
```

## Specify macros

To specify macros,
use the {nix:option}`~services.softIocs.<name>.macros` option:

```{code-block} nix
:caption: `softioc.nix` --- Creating a pvAccess SoftIOC

{
  services.softIocs.mySoftIOC = {
    dbFiles = [ ./mySoftIOC.db ];
    macros = {
      P = "MY:PREFIX:";
      CALC = "2 + 2";
    };
  };
}
```

## Specify bound port and other protocol parameters

To specify on which port the SoftIOC must listen,
and other Channel Access and pvAccess parameters,
use the {nix:option}`~services.softIocs.<name>.environment` option:

```{code-block} nix
:caption: `softioc.nix` --- Set Channel Access parameters

{
  services.softIocs.mySoftIOC = {
    dbFiles = [ ./mySoftIOC.db ];
    environment = {
      # Listen on port 5066
      EPICS_CAS_SERVER_PORT = "5066";
      # Only listen on this IP address
      EPICS_CAS_INTF_ADDR_LIST = "192.168.1.3";
    };
  };
}
```

:::{note}
The configuration set in {nix:option}`environment.epics`
also influences the SoftIOC environment,
and sets variables like `EPICS_CA_ADDR_LIST`,
`EPICS_CA_AUTO_ADDR_LIST`,
and related.
:::
