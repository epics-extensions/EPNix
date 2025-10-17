# Display Builder Web Runtime (DBWR)

The Display Builder Web Runtime (DBWR) is a service
that serves Phoebus `.bob` displays as web pages.

:::{seealso}
- the {nix:option}`services.dbwr` NixOS options
- the [DBWR README]
- the [PVWS README]
:::

## Enabling DBWR

To enable the DBWR service,
add this to your configuration:

```{code-block} nix
:caption: {file}`dbwr.nix`

{
  services.dbwr = {
    enable = true;
    openFirewall = true;
  };
}
```

This configuration starts a Tomcat server
on port 8080 by default,
with the DBWR and PV Web Socket (PVWS) web apps configured.

The {nix:option}`services.dbwr` NixOS module makes those applications available at:

- {samp}`http://{host-addr}:8080/dbwr/`
- {samp}`http://{host-addr}:8080/pvws/`

:::{seealso}
For a complete list of all DBWR- and PVWS-related options,
see {nix:option}`services.dbwr`.
:::

## Configuring the address list

The address list is configured by default
using the {nix:option}`environment.epics` module.
See the {doc}`epics-environment` guide for more information.

## Configuring DBWR and PVWS

PVWS and DBWR are configured through environment variables,
which you can pass through the {nix:option}`services.dbwr.settings` option.

For more information about available environment variables,
see the [DBWR README] and [PVWS README].

### Enabling write access

:::{caution}
If your PVs are restricted by Channel Access or PV Access access security,
it's recommended to put DBWR and PVWS behind authentication
via a reverse proxy.

Since the PVWS service handles PV writes,
the user seen by access security rules will be the Tomcat user.
:::

To enable write access from the web interface,
set the `PV_WRITE_SUPPORT` setting to `true`:

```{code-block} nix
:caption: {file}`dbwr.nix`
:emphasize-lines: 4

{
  services.dbwr = {
    # ...
    settings.PV_WRITE_SUPPORT = true;
  };
}
```

## Serve displays

DBWR doesn't provide displays by itself
but loads `.bob` files from a given "remote" URL.

To serve `.bob` files for DBWR,
you can start an nginx web server.

### From the NixOS configuration

```{code-block} nix
:caption: Serve `.bob` files from the NixOS configuration for DBWR

{
  services.nginx = {
    enable = true;
    # Serve the `bobs` directory next to this `.nix` file,
    # from the URL `http://localhost/`
    virtualHosts."localhost".locations."/".root = ./bobs;
  };
}
```

This configuration copies the {file}`./bobs` directory into the Nix store
and serves the `.bob` files from it.

Depending on your situation,
you can change `"localhost"` to your domain name
and `"/"` to the path where you want to serve the `.bob` displays.

### From another directory on the system

If you don't want to manage your `.bob` files from the NixOS configuration
but prefer a folder on the local system instead,
set the folder as an absolute path
and put quotes around it:

```{code-block} nix
:caption: Serve `.bob` files from a local folder for DBWR

{
  services.nginx = {
    enable = true;
    # Serve the local `/var/www/bobs` directory from the system
    # from the URL `http://localhost/`
    #
    # Note the quotes around the folder:
    virtualHosts."localhost".locations."/".root = "/var/www/bobs";
  };
}
```

Depending on your situation,
you can change `"localhost"` to your domain name
and `"/"` to the path where you want to serve the `.bob` displays.

  [DBWR README]: https://github.com/ornl-epics/dbwr
  [PVWS README]: https://github.com/ornl-epics/pvws
