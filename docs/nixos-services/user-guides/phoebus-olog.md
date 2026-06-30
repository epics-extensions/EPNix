# Phoebus Olog

Phoebus Olog is a service that serves as an online logbook,
for experimental and industrial logging.

You can install the Phoebus Olog service by using {nix:option}`services.phoebus-olog.enable`,
and configure it by using the other options in {nix:option}`services.phoebus-olog`.

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

:::{important}
The EPNix Phoebus Olog NixOS module
configures the service to listen for HTTP connections instead of HTTPS,
which is the opposite of default upstream.

That's because the upstream HTTPS configuration's private key
is publicly available in the Git repository,
making it insecure.

If you want an HTTPS service,
configure a reverse proxy that forwards connections
to the Phoebus Olog service.
:::

## Enabling the service

To enable the Phoebus Olog service,
add this to your configuration.

```{code-block} nix
:caption: {file}`phoebus-olog.nix`

{
  services.phoebus-olog = {
    enable = true;
    # If you want to expose your service as-is:
    openFirewall = true;

    # Choose your authentication providers,
    # see below for a list of available providers.
    settings.authenticationProviders = [ "XXX" ];
  };

  # Phoebus Olog needs ElasticSearch.
  # If not already enabled elsewhere in your configuration,
  # Enable it with the code below:
  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
  };

  # Elasticsearch, needed by Phoebus Olog, is not free software (SSPL | Elastic License).
  # To accept the license, add the code below:
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
```

:::{seealso}
For a complete list of options related to Phoebus Olog,
see {nix:option}`services.phoebus-olog`.
:::

## Custom port

To use a custom HTTP port,
set the {nix:option}`services.phoebus-olog.settings."server.port"` option:

```{code-block} nix
:caption: {file}`phoebus-olog.nix` --- Set custom HTTP port

{
  services.phoebus-olog = {
    enable = true;
    openFirewall = true;

    settings."server.port" = 1234;
  };

  # ...
}
```

## Authentication

Phoebus Olog supports multiple authentication providers,
which can be combined:

`inMemory`
:   *Not recommended for production servers*.
    Hard coded users and passwords.
    Provides 2 users:
    an administrator and a user.

`embeddedLdap`
:   At the start of the Phoebus Olog service,
    it starts an embedded LDAP server.

`ldap`
:   For a usage with an external LDAP server.

`activeDirectory`
:   For a usage with an external Microsoft Active Directory server.

:::{seealso}
Upstream's [Authentication](https://olog.readthedocs.io/en/latest/sysadmin/guides/configuring/authentication.html) documentation.
:::

### In memory

:::{caution}
This authentication type isn't recommended for production servers.
:::

This authentication configures 2 users:

- an admin `admin` with `adminPass` as password,
- and a user `user` with `userPass` as password.

To use it, set {nix:option}`services.phoebus-olog.settings.authenticationProviders` to
`[ "inMemory" ]`:

```{code-block} nix
:caption: {file}`phoebus-olog.nix` --- Default values for in memory authentication

{
  services.phoebus-olog = {
    enable = true;
    # ...

    settings = {
      "authenticationProviders" = [ "inMemory" ];
    };
  };

  # ...
}
```

### Embedded LDAP

With this authentication backend,
Phoebus Olog starts an embedded LDAP server,
which you can configure
by using the {nix:option}`services.phoebus-olog.settings.embedded_ldap_ldif` option.

This option must point to an [LDIF] file,
that has the content of the LDAP database.

Start by downloading the [{file}`olog.ldif`] file from the Phoebus Olog source code,
put it next to your {file}`phoebus-olog.nix` file,
and edit it to suit your needs.

Configure Phoebus Olog to use your LDIF file:

```{code-block} nix
:caption: {file}`phoebus-olog.nix` --- Configure the embedded LDAP authentication

{
  services.phoebus-olog = {
    enable = true;
    # ...

    settings = {
      "authenticationProviders" = [ "embeddedLdap" ];
      "spring.ldap.embedded.ldif" = "file://${./olog.ldif}";
    };
  };

  # ...
}
```

To generate a password,
use the {command}`mkpasswd` command:

```{code-block} bash
:caption: Generate a `bcrypt`-encrypted password

mkpasswd -m bcrypt
```

### External LDAP authentication

:::{note}
Configuring an fully featured LDAP server is out of scope for this guide.
See the [OpenLDAP NixOS Wiki page]
for how to configure an OpenLDAP server
on NixOS.
:::

This section assumes you already have a configured LDAP server.
This configured LDAP server can be an embedded LDAP server of another service.

If you want to use your company's LDAP server,
ask your IT team for the LDAP configuration.
The configuration must include:

- URL,
- base DN,
- user DN pattern,
- group search base,
- and group search path.

Here is an example configuration:

```{code-block} nix
:caption: {file}`phoebus-olog.nix` --- Configure the external LDAP authentication

{
  services.phoebus-olog = {
    enable = true;
    # ...

    settings = {
      "auth.impl" = "ldap";

      "ldap.urls" = "ldaps://auth.mycompany.com/dc=mycompany,dc=com";
      "ldap.base.dn" = "dc=mycompany,dc=com";
      "ldap.user.dn.pattern" = "uid={0},ou=People";
      "ldap.groups.search.base" = "ou=Group";
      "ldap.groups.search.pattern" = "(memberUid= {1})";
    };
  };

  # ...
}
```

  [LDIF]: https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format
  [{file}`olog.ldif`]: https://github.com/Olog/phoebus-olog/blob/master/src/main/resources/olog.ldif
  [OpenLDAP NixOS Wiki page]: https://wiki.nixos.org/wiki/OpenLDAP
