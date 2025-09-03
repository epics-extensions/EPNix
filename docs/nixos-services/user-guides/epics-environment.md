# EPICS environment

EPNix provides the {nix:option}`environment.epics` module,
enabled by default,
which configures standard EPICS configuration parameters.

It configures EPICS environment variables,
such as `EPICS_CA_ADDR_LIST` and `EPICS_CA_AUTO_ADDR_LIST`.
Those variables are set in any user session.

It also configures every EPNix service
that supports those parameters,
such as ChannelFinder, and Phoebus services.

:::{seealso}
[EPICS environment variables] in the Channel Access Reference Manual.
:::

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

## Default behavior

By default,
the Channel Access address list is empty,
and the "auto address list" parameter is set to yes.
From the Channel Access Reference Manual:

> For each interface found that is attached to a broadcast capable IP subnet,
> the broadcast address of that subnet is added to the list

If you don't want broadcast addresses to be discovered
for Channel Access,
set {nix:option}`environment.epics.ca_auto_addr_list` to `false`.

## Setting the address list

Use {nix:option}`environment.epics.ca_addr_list`
to set the Channel Access address list.

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
  };
}
```

## Extending the address list for a service

When you specify both {nix:option}`environment.epics.ca_addr_list`
and a service-specific configuration parameter,
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
for which you want a specific CA address list,
and bypass the use of the {nix:option}`environment.epics` module,
use `lib.mkForce`:

```{code-block} nix
:caption: Overriding the CA address list
:emphasize-lines: 1,13

{lib, ...}:
{
  environment.epics = {
    ca_addr_list = [
      "localhost"
      "192.168.1.42"
    ];
    ca_auto_addr_list = false;
  };

  # This list will *not* be merged with 'environment.epics.ca_addr_list'.
  services.phoebus-alarm-server.settings."org.phoebus.pv.ca/addr_list" =
    lib.mkForce [
      "192.168.1.5"
      "192.168.1.6"
    ];
}
```

:::{note}
The service still inherits other values specified under {nix:option}`environment.epics`.
:::

  [EPICS environment variables]: https://epics.anl.gov/base/R7-0/8-docs/CAref.html#EPICS
