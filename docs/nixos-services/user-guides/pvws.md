# PV WebSocket (PVWS)

The PV WebSocket (PVWS) service enables accessing various PVs (CA, PVA, and so on)
over a WebSocket.

:::{seealso}
- the {nix:option}`services.pvws` NixOS options
- the {doc}`dbwr` guide to serve Phoebus `.bob` files over HTTP
- the [PVWS README]
- the [default `application.properties` of PVWS]
:::

## Enabling PVWS

To enable the PVWS service,
add this to your configuration:

```{code-block} nix
:caption: {file}`pvws.nix`

{
  services.pvws = {
    enable = true;
    openFirewall = true;
  };

  # Uncomment if you use the "auto address list", which is the default,
  # or if you have broadcast addresses in your "address list":
  # --
  #environment.epics.allowCABroadcastDiscovery = true;
  #environment.epics.allowPVABroadcastDiscovery = true;
}
```

This configuration starts the PVWS server
on port 8080 by default.

The {nix:option}`services.pvws` NixOS module makes those applications available at:

- {samp}`http://{host-addr}:8080/pvws/`

## Configuring the address list

The address list is configured by default
using the {nix:option}`environment.epics` module.
See the {doc}`epics-environment` guide for more information.

## Configuring PVWS

You can configure PVWS
through the {nix:option}`services.pvws.settings` option,
which will generate PVWS' configuration file.

For more information about available settings,
see the [default `application.properties` of PVWS].

### Custom port

By default,
PVWS listens on HTTP port 8080.
To change it,
set the {nix:option}`services.pvws.settings."server.port"` option:

```{code-block} nix
:caption: {file}`pvws.nix` --- Set custom HTTP port
:emphasize-lines: 4

{
  services.pvws = {
    # ...
    settings."server.port" = 1234;
  };
}
```

(pvws-write-access)=
### Enabling write access

:::{caution}
If your PVs are restricted by Channel Access or PV Access access security,
it's recommended to put PVWS and related services behind authentication
via a reverse proxy.

Since the PVWS service handles PV writes,
the user seen by access security rules will be the PVWS user.
:::

To enable write access from the web interface,
set the `PV_WRITE_SUPPORT` setting to `true`:

```{code-block} nix
:caption: {file}`pvws.nix`
:emphasize-lines: 4

{
  services.pvws = {
    # ...
    settings.PV_WRITE_SUPPORT = true;
  };
}
```

  [PVWS README]: https://github.com/ornl-epics/pvws
  [default `application.properties` of PVWS]: https://github.com/ControlSystemStudio/pvws/blob/master/src/main/resources/application.properties
