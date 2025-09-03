# Phoebus client

The Phoebus graphical client is a graphical user-interface
for monitoring and operating large scale control systems,
such as the ones in the particle accelerator community.

You can install the Phoebus client by using {nix:option}`programs.phoebus-client.enable`,
and configure it by using the other options in {nix:option}`programs.phoebus-client`.

:::{important}
Make sure to follow the NixOS {doc}`prerequisites`.
:::

## Configure the preference settings

### By specifying settings

You can set Phoebus preference settings by using {nix:option}`programs.phoebus-client.settings`.
See the [Phoebus Preferences Listing] page for a list of available settings.

```{code-block} nix
:caption: Configuring Phoebus client preference settings

{
  programs.phoebus-client = {
    enable = true;
    settings = {
      "org.phoebus.applications.alarm/server" = "my-kafka-server:9092";
      "org.phoebus.applications.alarm.logging.ui/service_uri" = "http://my-logger-server:8080";
      "org.phoebus.applications.saveandrestore/jmasar.service.url" ="http://my-sar-server:8080/save-restore";

      # Macros are specified as an attribute set:
      "org.csstudio.display.builder.model/macros" = {
        EXAMPLE_MACRO = "example macro value";
      };
    };
  };
}
```

(phoebus-settings-file)=
### By using a settings file

If you want to use a {file}`settings.ini` file,
use the {nix:option}`programs.phoebus-client.settingsFile` option:

```{code-block} nix
:caption: Use {file}`phoebus-client-settings.ini` as configuration file

{
  programs.phoebus-client = {
    # ...
    settingsFile = ./phoebus-client-settings.ini;
  };
}
```

Phoebus supports reading a settings file
from an HTTP server:

```{code-block} nix
:caption: Use remote file as configuration file

{
  programs.phoebus-client = {
    # ...
    settingsFile = "https://my-server/phoebus/settings.ini";
  };
}
```

You can also use Nix' package management
to depend on a settings file in another location,
for example by using `pkgs.fetchUrl`,
or by using flakes:

```{code-block} nix
:caption: Use Nix flakes to import a remote file as configuration file
:emphasize-lines: 3-6,12,21

{
  # ...
  inputs.my-config-repo = {
    url = "git+ssh://git@my-gitlab-server.com/MyProject/my-config-repo.git";
    flake = false;
  };
  # ...

  outputs = {
    self,
    # ...
    my-config-repo,
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        # ...

        {
          programs.phoebus-client = {
            # ...
            settingsFile = "${my-config-repo}/phoebus/settings.ini";
          };
        };

      ];
    };
  };
}
```

## Configure the address list

The {nix:option}`programs.phoebus-client.settings` module uses the values
from the {nix:option}`environment.epics` module by default.
See the {doc}`epics-environment` guide for mode information.

:::{warning}
If you configured Phoebus by using a [settings file](#phoebus-settings-file),
{nix:option}`environment.epics` options are ignored.
:::

## Configure the colors

(phoebus-color-def)=
### By specifying settings

To configure the colors directly,
use the {nix:option}`programs.phoebus-client.colorDef` option.
See the option documentation for the color format.

```{code-block} nix
:caption: Configuring Phoebus client colors

{
  programs.phoebus-client = {
    # ...

    colorDef = rec {
      OK = "0, 255, 0";
      On = OK;
      Transparent = "255, 255, 255, 0";
    };
  };
}
```

:::{tip}
Nix doesn't keep the ordering of attribute set,
so a configuration such as this does *not* work:

```{code-block} nix
:caption: Incorrect example of color definitions

{
  programs.phoebus-client.colorDef = {
    B = "0, 255, 0";
    # The color A won't work,
    # since A will be placed before "B"
    A = "B";
  };
}
```

Instead,
you can use the `rec` Nix feature,
to use other attributes as variables:

```{code-block} nix
:caption: Valid example of color definitions

{
  # Note the "rec" before the attribute set
  programs.phoebus-client.colorDef = rec {
    B = "0, 255, 0";
    # B gets resolved by Nix,
    # and replaced with "0, 255, 0".
    # Note the lack of quotes
    A = B;

    # You can also refer to other colors
    # before their definition:
    C = D;
    D = "1, 2, 3";
  };
}
```
:::

:::{warning}
If you set {nix:option}`programs.phoebus-client.colorDef`,
the "additional colors" from [{file}`examples/color.def`],
such as `Header_Background`, `On`, or `Off`,
won't be provided by default.
:::

### By using a settings file

If you want to use a {file}`color.def` file,
use the {nix:option}`programs.phoebus-client.settings."org.csstudio.display.builder.model/color_files"` option:

```{code-block} nix
:caption: Use {file}`phoebus-client-color.def` as configuration file

{
  programs.phoebus-client = {
    # ...
    settings."org.csstudio.display.builder.model/color_files" = ./phoebus-client-color.def;
  };
}
```

## Configure the fonts

### By specifying settings

To configure the fonts directly,
use {nix:option}`programs.phoebus-client.fontDef` option.
See the option documentation
for the font format.

```{code-block} nix
:caption: Configuring Phoebus client colors

{
  programs.phoebus-client = {
    # ...

    fontDef = rec {
      Oddball = "Comic Sans MS-regular-40";
      "Oddball(linux)" = "PakTypeNaqsh-regular-40";
      "Oddball(macosx)" = "Herculanum-regular-40";

      Liberation = "Liberation Serif-regular-40";
      Serif = Liberation;
    };
  };
}
```

:::{tip}
As with colors,
prefer using the `rec` Nix feature
instead of using the `@` Phoebus syntax
for referring to fonts declared before.

See the tip in the [color settings section](#phoebus-color-def).
:::

### By using a settings file

If you want to use a {file}`font.def` file,
use the {nix:option}`programs.phoebus-client.settings."org.csstudio.display.builder.model/font_files"` option:

```{code-block} nix
:caption: Use {file}`phoebus-client-font.def` as configuration file

{
  programs.phoebus-client = {
    # ...
    settings."org.csstudio.display.builder.model/font_files" = ./phoebus-client-font.def;
  };
}
```

## Set the Java virtual machine options

If you want to tune the JVM,
use the {nix:option}`programs.phoebus-client.java_opts` option.
See the option documentation for its default value.

```{code-block} nix
:caption: Changing the options passed to the JVM

{
  programs.phoebus-client = {
    # ...
    java_opts = "-XX:MinHeapSize=128m -XX:MaxHeapSize=4g -XX:InitialHeapSize=1g";
  };
}
```

  [Phoebus Preferences Listing]: https://control-system-studio.readthedocs.io/en/latest/preference_properties.html
  [{file}`examples/color.def`]: https://github.com/ControlSystemStudio/phoebus/blob/master/app/display/model/src/main/resources/examples/color.def
