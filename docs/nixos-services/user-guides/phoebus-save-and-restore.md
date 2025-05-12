# Phoebus save-and-restore setup

The Phoebus save-and-restore service is used by clients
to manage configuration and snapshots of PV values.
These snapshots can then be used by clients for comparison or for restoring process variables.

This guide focuses on installing and configuring the save-and-restore service on a single server.

For more details and documentation about Phoebus save-and-restore,
you can examine the [save-and-restore official documentation].

```{include} ./pre-requisites.md
```

## Enabling the Phoebus save-and-restore service

To enable the Phoebus save-and-restore service,
add this to your configuration:

```{code-block} nix
:caption: {file}`phoebus-save-and-restore.nix`

{lib, ...}: {
  services.phoebus-save-and-restore = {
    enable = true;
    openFirewall = true;

    # Choose your authentication implementation
    # see below for a list of available backends
    settings."auth.impl" = "XXX";
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
```

:::{seealso}
For a complete list of options related to Phoebus save-and-restore,
see {nix:option}`services.phoebus-save-and-restore`.
:::

From the Phoebus graphical client side,
add this configuration

```{code-block} ini
:caption: {file}`phoebus-client-settings.ini`

# Replace the IP address with your server's IP address or domain name
org.phoebus.applications.saveandrestore/jmasar.service.url=http://192.168.1.42:8080/save-restore
```

## Custom port

To use a custom HTTP port,
set the {nix:option}`services.phoebus-save-and-restore.settings."server.port"`.

For example:

```{code-block} nix
:caption: {file}`phoebus-save-and-restore.nix` --- Set custom HTTP port

{
  services.phoebus-save-and-restore = {
    enable = true;
    openFirewall = true;

    settings."server.port" = 1234;
  };

  # ...
}
```

## Authentication

Phoebus save-and-restore supports these authentication backends,
which you can select
by using the {nix:option}`services.phoebus-save-and-restore.settings."auth.impl"` option:

Demo (`"demo"`)
:   *Not recommended for production servers*.
    Hard coded users and passwords.
    Provides 3 users:

    -   an admin
    -   a read-only user
    -   a normal user

Embedded LDAP (`"ldap_embedded"`)
:   At the start of the Phoebus save-and-restore service,
    it starts an embedded LDAP server.

LDAP (`"ldap"`)
:   For a usage with an external LDAP server.

Microsoft Active Directory (`"ad"`)
:   For a usage with an external Microsoft Active Directory server.

### Demo authentication

:::{caution}
This authentication type isn't recommended for production servers.
:::

This authentication lets you configure 3 users
and their passwords
in plain text in the configuration.

Here are the settings that are used,
and their default values:

```{code-block} nix
:caption: {file}`phoebus-save-and-restore.nix` --- Default values for demo authentication

{
  services.phoebus-save-and-restore = {
    enable = true;
    # ...

    settings = {
      "auth.impl" = "demo";

      "demo.admin" = "admin";
      "demo.admin.password" = "adminPass";
      "demo.readOnly" = "johndoe";
      "demo.readOnly.password" = "1234";
      "demo.user" = "user";
      "demo.user.password" = "userPass";
    };
  };

  # ...
}
```

### Embedded LDAP authentication

:::{caution}
Currently Phoebus doesn't support encrypted passwords in LDIF files.
This means that password are stored in plain text
in your Git repositories,
and in the world-readable Nix store.

If this isn't acceptable,
setup and use an external LDAP or AD server.
:::


With this authentication backend,
Phoebus save-and-restore starts an embedded LDAP server,
which you can configure
by using the {nix:option}`services.phoebus-save-and-restore.settings."spring.ldap.embedded.ldif"` option.

This option must point to an [LDIF] file,
that has the content of the LDAP database.

This file must define two groups: `sar-user` and `sar-admin`.
For more information about these roles,
see [Phoebus save-and-restore's Authentication and Authorization] documentation.

Start by downloading the [{file}`sar.ldif`] file from the Phoebus source code,
put it next to your {file}`phoebus-save-and-restore.nix` file,
and edit it to suit your needs.

Configure Phoebus save-and-restore to use your LDIF file:

```{code-block} nix
:caption: {file}`phoebus-save-and-restore.nix` --- Configure the embedded LDAP authentication

{
  services.phoebus-save-and-restore = {
    enable = true;
    # ...

    settings = {
      "auth.impl" = "ldap_embedded";
      "spring.ldap.embedded.ldif" = "file://${./sar.ldif}";
    };
  };

  # ...
}
```

#### Changing a user name

To change a user name,
set its "user ID" (`uid`)
and "common name" (`cn`):

```{code-block} ldif
:caption: {file}`sar.ldif` --- Changing a user name
:emphasize-lines: 3-4, 8
:name: user-name-change

# ...

dn: uid=custom-user,ou=Group,dc=sar,dc=local
uid: custom-user
objectClass: account
objectClass: posixAccount
description: User with sar-user role
cn: custom-user
userPassword: XXX
uidNumber: 23004
gidNumber: 23004
homeDirectory: /dev/null

# ...
```

:::{important}
Make sure to replace every `memberUid:` line that referenced the old user name.
:::

#### Setting a user password

To set an plain text password,
set the `userPassword` field:

```{code-block} ldif
:caption: {file}`sar.ldif` --- Changing a user password
:emphasize-lines: 9

# ...

dn: uid=custom-user,ou=Group,dc=sar,dc=local
uid: custom-user
objectClass: account
objectClass: posixAccount
description: User with sar-user role
cn: custom-user
userPassword: my-custom-user-password
uidNumber: 23004
gidNumber: 23004
homeDirectory: /dev/null

# ...
```

#### Creating a new user

To create a new user,
copy and paste a block that has the `posixAccount` class,
such as the one presented in {ref}`user-name-change`.

Make sure that its `uidNumber` and `gidNumber` are unique.

#### Adding a user to a group

To add a user to a group:

1.  go to the block that defines the group,

    :::{hint}
    The block must have the `posixGroup` class,
    and should be named `sar-user` or `sar-admin`.
    :::

2.  and add a `memberUid:` line with your user name.

For example,
to add the user "custom-user" to the group "sar-user":

```{code-block} ldif
:caption: {file}`sar.ldif` --- Adding "custom-user" to the group "sar-user"
:emphasize-lines: 10

# ...

dn: cn=sar-user,ou=Group,dc=sar,dc=local
cn: sar-user
objectClass: posixGroup
description: save-n-restore user
gidNumber: 27001
uidNumber: 27001
memberUid: user
memberUid: custom-user

# ...
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
:caption: {file}`phoebus-save-and-restore.nix` --- Configure the external LDAP authentication

{
  services.phoebus-save-and-restore = {
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

  [Phoebus save-and-restore's Authentication and Authorization]: https://control-system-studio.readthedocs.io/en/latest/services/save-and-restore/doc/index.html#authentication-and-authorization
  [{file}`sar.ldif`]: https://github.com/ControlSystemStudio/phoebus/blob/master/services/save-and-restore/src/main/resources/sar.ldif
  [LDIF]: https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format
  [OpenLDAP NixOS Wiki page]: https://wiki.nixos.org/wiki/OpenLDAP
  [save-and-restore official documentation]: https://control-system-studio.readthedocs.io/en/latest/services/save-and-restore/doc/index.html
