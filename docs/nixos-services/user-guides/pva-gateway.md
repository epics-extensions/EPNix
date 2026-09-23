# PVA gateway

The pvAccess (PVA) gateway is a program
that acts as gateway,
which enables pvAccess clients from a network
to access pvAccess IOCs on another network.

Setting up a PVA gateway also enables you
to add extra access security rules on top of IOCs.

For more details and documentation about the PVA PV gateway,
you can examine the {external+p4p:ref}`gwpage` documentation.

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

:::{seealso}
For a complete list of all PVA gateway-related NixOS options,
see {nix:option}`services.pva-gateway`.

For a complete list of all options available in {nix:option}`services.pva-gateway.settings`,
see the {external+p4p:ref}`gwconfref` P4P gateway documentation.
:::

## Enabling the gateway

To enable the gateway,
add this to your configuration:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Basic configuration

{
  services.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        { name = "client"; }
      ];
      servers = [
        { name = "server"; }
      ];
    };
  };

  environment.epics.openPVAFirewall = true;
  # Since this configuration uses an "auto address list" which sends broadcasts,
  # the firewall must be configured to allow broadcast replies.
  # Remove if none of your PVA gateway clients use an "auto address list"
  # nor a manual broadcast address.
  environment.epics.allowPVABroadcastDiscovery = true;
}
```

In this configuration,
the PVA gateway starts a `pva-gateway.service` systemd service,
which listens on all interface,
and forwards all pvAccess requests by broadcasting
on all interfaces.

## Restricting clients and servers

To restrict where the PVA gateway listens for pvAccess requests,
use the {nix:option}`~services.pva-gateway.settings.servers.*.interface` option:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Restricting the server

{
  servers.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        # ...
      ];
      servers = [
        {
          name = "server10";
          # Listen only for requests addressed to 10.1.1.4
          interface = [ "10.1.1.4" ];
        }
      ];
    };
  };

  # ...
}
```

To restrict where the PVA gateway forward pvAccess requests,
use the {nix:option}`services.pva-gateway.settings.clients.*.addrlist` option:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Restricting the client

{
  servers.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        {
          name = "client192";
          # Forward pvAccess requests by broadcasting to 192.168.1.*
          addrlist = [ "192.168.1.255" ];
          autoaddrlist = false;
        }
      ];
      servers = [
        # ...
      ];
    };
  };

  # ...
}
```

## Status PVs

The PVA gateway can provide status and statistics PVs.
To enable them,
set the {nix:option}`services.pva-gateway.settings.servers.*.statusprefix` option,
for example:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Enabling status PVs
:emphasize-lines: 12

{
  servers.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        # ...
      ];
      servers = [
        {
          name = "server10";
          # ...
          statusprefix = "GW:STS:";
        }
      ];
    };
  };

  # ...
}
```

:::{seealso}
{external+p4p:ref}`gwstatuspvs` in the P4P documentation
for the complete list of status PVs.
:::

## Restricting PVs

By using the {nix:option}`services.pva-gateway.settings.servers.*.pvlist` option,
you can filter which PVs get exposed by the gateway.

This option takes a file in the gateway `pvlist` format.
See {external+p4p:ref}`gwpvlist` in the P4P documentation.

### In the configuration

For example:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Adding a PV list inline
:emphasize-lines: 1,17-28

{ pkgs, ... }:
{
  services.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        # ...
      ];
      servers = [
        {
          name = "myserver";
          # ...
          # These PVs get exposed by the gateway
          # This list implements a "blocklist":
          # ALLOW by default, some PVs explicitly DENY.
          # Note that the PVA gateway doesn't currently supports "EVALUATION ORDER DENY, ALLOW"
          pvlist = pkgs.writeText "gateway.pvlist" ''
            EVALUATION ORDER ALLOW, DENY

            .* ALLOW

            MY_PV1 DENY
            MY_PV2 DENY

            # Or:

            MY_PV[0-9]+ DENY
          '';
        }
      ];
    };
  };
}
```

### In a separate file

For long lists,
it can be better
to put it in a separate file.
You can do this
by adding a {file}`gateway.pvlist` in the same directory as your configuration,
and set:

```{code-block} nix
:caption: {file}`pva-gateway.nix` --- Adding a PV list as a separate file
:emphasize-lines: 14

{
  services.pva-gateway = {
    enable = true;
    settings = {
      clients = [
        # ...
      ];
      servers = [
        {
          name = "myserver";
          # ...
          # Make sure that the value is *not* quoted,
          # and make sure to `git add` the file.
          pvlist = ./gateway.pvlist;
        }
      ];
    };
  };
}
```
