# EPICS environment

EPNix provides the {nix:option}`environment.epics` module,
enabled by default,
which configures standard EPICS configuration parameters.

It configures EPICS environment variables,
such as {envvar}`EPICS_CA_ADDR_LIST`, {envvar}`EPICS_CA_AUTO_ADDR_LIST`,
{envvar}`EPICS_PVA_ADDR_LIST`,
and so on.
Those variables are set for every user session.

It also configures every EPNix service
that supports those parameters,
such as ChannelFinder, and Phoebus services.

:::{seealso}
- {external+epics:ref}`ca-client-env-vars` in the Channel Access Reference Manual.
- [PVA Network Configuration] in the PVXS Manual.
:::

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

## Default behavior

By default,
the Channel Access and pvAccess address lists are empty,
and the "auto address list" parameter is set to yes.
From the Channel Access Reference Manual:

> For each interface found that is attached to a broadcast capable IP subnet,
> the broadcast address of that subnet is added to the list

If you don't want broadcast addresses to be discovered,
set {nix:option}`environment.epics.ca_auto_addr_list` to `false`
for Channel Access,
and set {nix:option}`environment.epics.pva_auto_addr_list` to `false`
for pvAccess.

## Setting the address list

Use {nix:option}`environment.epics.ca_addr_list`
to set the Channel Access address list,
or use {nix:option}`environment.epics.pva_addr_list`
to set the pvAccess address list.

```{code-block} nix
:caption: Setting a manual CA address list

{
  environment.epics = {
    ca_addr_list = [
      "localhost"
      "192.168.1.42"
      "192.168.1.42:5066"
      "192.168.1.42:5067"
    ];
    # Don't use discovered broadcast addresses
    ca_auto_addr_list = false;

    # Same but for pvAccess
    pva_addr_list = [
      ...
    ];
    pva_auto_addr_list = false;
  };
}
```

## Extending the address list for a service

When you specify the address list both globally
and as a service-specific configuration parameter,
Nix merges both address lists.

For example,
if you set:

```{code-block} nix
:caption: Manually extending the CA address list

{
  environment.epics = {
    ca_addr_list = [
      "localhost"
      "192.168.1.42"
    ];
    ca_auto_addr_list = false;
  };

  # This list is merged with 'environment.epics.ca_addr_list'.
  services.phoebus-alarm-server.settings."org.phoebus.pv.ca/addr_list" = [
    "192.168.1.5"
    "192.168.1.6"
  ];
}
```

The Phoebus Alarm Server's CA address list,
in its `.properties` file,
would contain:

-   `192.168.1.5`
-   `192.168.1.6`
-   `localhost`
-   `192.168.1.42`

## Overriding the address list for a service

If you have a service,
for which you want a specific an address list,
and bypass the use of the {nix:option}`environment.epics` module,
use `lib.mkForce`:

```{code-block} nix
:caption: Overriding the PVA address list
:emphasize-lines: 1,13

{lib, ...}:
{
  environment.epics = {
    pva_addr_list = [
      "localhost"
      "192.168.1.42"
    ];
    pva_auto_addr_list = false;
  };

  # This list will *not* be merged with 'environment.epics.ca_addr_list'.
  services.phoebus-alarm-server.settings."org.phoebus.pv.pva/epics_pva_addr_list" =
    lib.mkForce [
      "192.168.1.5"
      "192.168.1.6"
    ];
}
```

:::{note}
The service still inherits other values specified under {nix:option}`environment.epics`.
:::

  [PVA Network Configuration]: https://epics-base.github.io/pvxs/netconfig.html "PVXS Manual"
