# ChannelFinder service setup

ChannelFinder is a directory service which enables searching for PV names,
called *channels names*,
and associated metadata.

A ChannelFinder server is usually combined with a "RecCaster" module in the IOC,
that sends the metadata,
and a "RecCeiver" server
that scans and retrieves the metadata from "RecCaster."

For more information on the ChannelFinder architecture,
see the official [ChannelFinder introduction].

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

## ChannelFinder service

To enable the ChannelFinder service,
use {nix:option}`services.channel-finder.enable` and related options.
You will also need to enable ElasticSearch.

For example:

```{code-block} nix
:caption: {file}`channel-finder.nix` --- ChannelFinder configuration example

{lib, pkgs, ...}: {
  services.channel-finder = {
    enable = true;
    openFirewall = true;
    settings = {

      # Choose your authentication type (see below for explanations)
      # ---
      #"demo_auth.enabled" = true;
      #"ldap.enabled" = true;

      "server.port" = 8444;
      "server.http.port" = 8082;
    };
  };

  # Install Elasticsearch,
  # because it's a ChannelFinder service dependency
  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
  };

  # Elasticsearch, needed by ChannelFinder, is not free software (SSPL | Elastic License).
  # To accept the license, add the code below:
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
```

This configuration starts the ChannelFinder service on port 8082.
You can open your browser at <http://localhost:8082/> to see the ChannelFinder admin page.

For more settings,
examine the [ChannelFinder configuration] reference
and the {nix:option}`services.channel-finder.settings` option.

### Authentication

ChannelFinder supports different types of authentication backends:

Demo authentication

: *Not recommended for production servers*.
  Users,
  their roles,
  and passwords
  are specified in the configuration file,
  in plain text.

External LDAP server

: The ChannelFinder service connects to an external LDAP server,
  and uses it for authentication and role assignment.

  :::{note}
  Configuring an fully-featured LDAP server is out of scope for this guide,
  but the ChannelFinder service can connect to another service's embedded LDAP server.

  For example,
  ChannelFinder could connect to a Phoebus Olog's embedded LDAP server configured beforehand.
  :::

#### Demo authentication

:::{caution}
This authentication type is not recommended for production servers.
:::

Users,
roles,
and passwords
are stored as comma-separated list in the configuration.

For example:

```{code-block} nix
:caption: {file}`channel-finder.nix` --- demo authentication example

services.channel-finder = {
  settings = {
    "demo_auth.enabled" = true;
    "demo_auth.users" = "admin,operator,expert";
    "demo_auth.pwd" = "adminPass,operatorPass,expertPass";
    # Multiple roles can be given by separating them with ':'
    "demo_auth.roles" = "ADMIN:EXPERT,USER,USER:EXPERT";
  };
};
```

#### External LDAP server

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
:caption: {file}`channel-finder.nix` --- external LDAP authentication example

services.channel-finder = {
  settings = {
    "ldap.enabled" = true;
    "ldap.urls" = "ldaps://auth.mycompany.com/dc=mycompany,dc=com";
    "ldap.user.dn.pattern" = "uid={0},ou=People,dc=mycompany,dc=com";
    "ldap.groups.search.base" = "ou=Group,dc=mycompany,dc=com";
    "ldap.groups.search.pattern" = "(memberUid= {1})";
  };
};
```

## RecCeiver

The RecCeiver service scans for IOCs in the network,
and fetches the list of PV names and other metadata.
You can configure it to put this information into the ChannelFinder service.

Use the `channelfinderapi.DEFAULT` setting for configuring the connection to the ChannelFinder service,
and use the `settings` option for configuring all other settings.

For a list of available `settings`,
examine the [RecCeiver demo.conf] file.

Also examine the {nix:option}`services.recceiver.channelfinderapi`
and {nix:option}`services.recceiver.settings` options.

TODO: explain which cf role is needed

For example:

```{code-block} nix
:caption: {file}`channel-finder.nix` --- RecCeiver configuration example
:name: recceiver-configuration-example

{lib, pkgs, ...}: {
  # Other previous options...

  services.recceiver = {
    enable = true;

    channelfinderapi.DEFAULT = {
      username = "admin";
      password = "adminPass";
    };

    settings = {
      recceiver = {
        # Necessary if you want a firewall,
        # which is enabled by default in NixOS.
        bind = "0.0.0.0:5050";

        # When receiving metadata,
        # print it on the command-line (show),
        # and send it to ChannelFinder (cf).
        procs = ["show" "cf"];
      };
      cf = {
        # PV metadata to send to ChannelFinder
        alias = "on";
        recordDesc = "on";
        recordType = "on";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [5050];
}
```

(recceiver-firewall)=
### Firewall

If `settings.bind` is unset,
RecCeiver listens on a random port,
which makes it difficult to open the firewall.

To open the firewall,
make sure to set the bind address to a fixed port,
and open it in the firewall as TCP,
as shown in the {ref}`recceiver-configuration-example`.

On the IOC side,
the firewall needs to allow the UDP announcer port,
which by default is 5049.

If your IOC is a NixOS machine,
you can open the firewall with this configuration:

```{code-block} nix
:caption: Opening the IOC's firewall for RecCaster

networking.firewall.allowedUDPPorts = [5049];
```

### Setting the address list

If you want to scan a specific network,
or if you want to change the port number used for scanning,
you can use the `settings.recceiver.addrlist` option.

:::{warning}
If you change the port,
make sure to also change it in the IOC firewall rules.

See {ref}`recceiver-firewall`.
:::

```{code-block} nix
:caption: {file}`channel-finder.nix` --- changing the RecCeiver address list

{lib, pkgs, ...}: {
  # ...

  services.recceiver = {
    # ...
    settings = {
      recceiver = {
        # ...

        # If you change the port,
        # make sure to also change it in the IOC firewall rules
        addrlist = ["192.168.1.255:5049"];
      };
      # ...
    };
  };

  # ...
}
```

(recceiver-custom-metadata)=
### Custom metadata

To add custom metadata variable to the ChannelFinder service,
use the `settings.cf.environment_vars` option,
for example:

```{code-block} nix
:caption: {file}`channel-finder.nix` --- adding custom metadata to ChannelFinder

{lib, pkgs, ...}: {
  # ...

  services.recceiver = {
    # ...
    settings = {
      # ...
      cf = {
        # ...
        environment_vars = {
          # Follows the pattern:
          # IOC_VARIABLE = "ChannelFinderProperty";
          CONTACT = "Concact";
          EPICS_BASE = "EpicsBase";
          EPICS_VERSION = "EpicsVersion";
          PWD = "WorkingDirectory";
        };
      };
    };
  };
};
```

### External ChannelFinder server

If your ChannelFinder server is located on another machine,
use the `channelfinderapi.DEFAULT.BaseURL` option:

```{code-block} nix
:caption: {file}`channel-finder.nix` --- specifying an external ChannelFinder server

  services.recceiver = {
    # ...

    channelfinderapi.DEFAULT = {
      BaseURL = "http://192.168.1.42:8082/ChannelFinder";
      # ...
    };

    # ...
  };
```

## RecCaster

To configure RecCaster in your IOCs,
examine the guide {doc}`../../ioc/user-guides/reccaster`.

[channelfinder configuration]: https://channelfinder.readthedocs.io/en/latest/config.html
[channelfinder introduction]: https://channelfinder.readthedocs.io/en/latest/overview.html
[recceiver demo.conf]: https://github.com/ChannelFinder/recsync/blob/1.6/server/demo.conf
