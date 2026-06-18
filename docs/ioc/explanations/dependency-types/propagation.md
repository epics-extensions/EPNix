# Dependency propagation

:::{seealso}
The [Nixpkgs "Dependency propagation" section].
:::

## General concept

Consider the case where `C` depends on `A` and `B`,
and `D` depends on `C`.
To declare `A` a "propagated" dependency means
that `D` automatically depends on `A`.

```{graphviz}
:alt: Diagram of a propagated dependency
:caption: Dependency propagation

digraph propagation {
    rankdir="LR"

    C -> A [label="propagated",color="#81a1c1"]
    C -> B [label="not propagated",color="#bf616a"]
    D -> C [color="#81a1c1"]
    D -> A [style="dashed",label="automatic",color="#81a1c1"]
}
```

This specificity comes from Nix building dependencies in a sandbox.
During the build of `D` in this example,
`A` and `C` are available in the sandbox,
while `B` isn't,
despite being available in the {file}`/nix/store`.

Here is an example build plan for `D`:

1. Fetch or build `B` and put it in the {file}`/nix/store`.
2. Fetch or build `A` and put it in the {file}`/nix/store`.
3. Fetch or build `C` and put it in the {file}`/nix/store`.
4. Build `D`.
   Only `C` and `A` are exposed
   in the build sandbox.

:::{important}
When packaging an EPICS support module,
its EPICS support module dependencies need to be propagated.
:::

For example,
if we were to package {nix:pkg}`epnix.support.StreamDevice`,
we would need to specify {nix:pkg}`epnix.support.asyn` as a propagated dependency:
an IOC depending on `StreamDevice` must have access to `asyn` during its build.

## Why EPICS support modules need to be propagated

When there's a transitive EPICS dependency,
these dependencies tend to be "leaky."
For example,
when developing a `StreamDevice` IOC,
your IOC needs to manually include bits from `asyn`.

The `asyn` library should be an implementation detail of `StreamDevice`,
but it "leaks" through,
and your IOC needs to know about it.

This is a problem common
to many transitive EPICS dependencies,
which is why we recommend that packages propagate these dependencies.

In the following sections,
we'll see why this is often the case
with concrete examples.

:::{seealso}
[Leaky abstraction] on Wikipedia
:::

### StreamDevice and asyn example

```{graphviz}
:alt: Diagram of an IOC depending on StreamDevice
:caption: IOC depending on StreamDevice

digraph asyn_stream {
    rankdir="LR"

    "StreamDevice" -> "asyn" [label="propagated",color="#81a1c1"]
    "StreamDevice" -> "libpcre" [label="not propagated",color="#bf616a"]
    "An IOC" -> "StreamDevice"
    "An IOC" -> "asyn" [style="dashed",label="automatic",color="#81a1c1"]
}
```

Running a Nix build of the IOC might go like this:

1. Fetch or build `libpcre` and put it in the {file}`/nix/store`.
2. Fetch or build `asyn` and put it in the {file}`/nix/store`.
3. Fetch or build `StreamDevice` and put it in the {file}`/nix/store`.
4. Build the IOC.
   Only `StreamDevice` and `asyn` are exposed
   in the build sandbox.

This transitive dependency on `asyn` must be propagated
because in your IOC files,
you have to specify that your app links to both the `StreamDevice` library
and the `asyn` library.
Your IOC also needs to import the `stream.dbd` and `asyn.dbd` files.

In the diagram,
you can see `StreamDevice` depending on the `libpcre` system library,
but that dependency isn't propagated.
Why does `StreamDevice` need to propagate `asyn` but not `libpcre`?

The `libpcre` project is a library that `StreamDevice` uses
to implement [Regular Expressions].

In a protocol file,
you can specify that you expect a device to send you a message
in the format `%.1/<title>(.*)<\/title>/`.
The `StreamDevice` support module parses this regular expression
by using the PCRE library
and will try to match incoming messages.

When your IOC is running,
you have EPICS records with the `stream` device type,
which will call functions defined in the {file}`libstream.so` library.
This library will call functions defined in the {file}`libpcre.so` library,
so your app doesn't need to know about it.

```{graphviz}
:caption: Using a regular expression with `StreamDevice`
:alt: Diagram of the dependency chain of using a RegExp in a StreamDevice record

digraph streamdevice_regex {
    rankdir="LR"

    subgraph cluster_top {
        label="An EPICS top"

        sd [label="StreamDevice\nrecord",style="filled"]
        "An IOC" -> sd
    }

    subgraph cluster_streamdevice {
        label="StreamDevice"
        libstream [label="libstream.so"]
    }

    sd -> libstream [label="calls"]

    subgraph cluster_libpcre {
        label="libpcre"
        libpcre [label="libpcre.so"]
    }

    libstream -> libpcre [label="calls"]
}
```

The PCRE library can stay an implementation detail of `StreamDevice`.

When using `StreamDevice` in an IOC,
you need to include several bits from `asyn`.
You'll often find a {file}`{yourApp}/src/Makefile` file
with these lines:

```{code-block} make
:caption: App Makefile that includes EPICS support module database definition files

yourApp_DBD += asyn.dbd
yourApp_DBD += calc.dbd
yourApp_DBD += stream.dbd
yourApp_DBD += drvAsynIPPort.dbd
```

Both {file}`asyn.dbd` and `drvAsynIPPort.dbd` are useful
for typical `StreamDevice` usage:

- `drvAsynIPPort.dbd` defines the `drvAsynIPPortConfigure` shell function
  for configuring TCP/IP communication with the device
- `asyn.dbd` defines the `asynSetOption` shell function
  and the [`asyn` record type]

These functions and record types are implemented in {file}`libasyn.so`,
which is why you also need to link directly to this library:

```{code-block} make
:caption: App Makefile that links to EPICS support modules libraries

yourApp_LIBS += asyn
yourApp_LIBS += calc
yourApp_LIBS += stream
```

```{graphviz}
:caption: Build-time dependencies to `StreamDevice` and asyn

digraph asyn_streamdevice_build_deps {
    subgraph cluster_top {
        label="An EPICS top"
        { rank="same"
          app [label="An App"]
          Makefile -> app [label="builds"]
        }
    }

    subgraph cluster_streamdevice {
        label="StreamDevice"
        libstream [label="libstream.so"]
        stream_dbd [label="stream.dbd"]
    }

    subgraph cluster_asyn {
        label="asyn"
        libasyn [label="libasyn.so"]
        asyn_dbd [label="asyn.dbd"]
        drv_asyn [label="drvAsynIPPort.dbd"]
    }

    Makefile -> stream_dbd [label="includes"]
    Makefile -> asyn_dbd [label="includes"]
    Makefile -> drv_asyn [label="includes"]
    app -> libstream [label="links to"]
    app -> libasyn [label="links to"]
    libstream -> libasyn [label="links to"]
}
```

### `autosave` and `busy` example

Another example is how using the {nix:pkg}`epnix.support.autosave` support module
might lead you to manually load the {nix:pkg}`epnix.support.busy` support module.

When using `autosave`,
you have the option to use the ["config menu" feature].
To use this feature,
you need to load the {file}`configMenu.db`
from the `autosave` package.

This database file has a `busy` record type,
which means your app must now know about the `busy` module.

```{graphviz}
:caption: Dependencies to autosave and busy

digraph autosave_busy {
    subgraph cluster_top {
        label="An EPICS top"
        ioc [label="An IOC"]
    }

    subgraph cluster_autosave {
        label="autosave"
        configMenu [label="configMenu.db"]
        libautosave [label="libautosave.so"]
    }

    subgraph cluster_busy {
        label="busy"
        busy_record [label="busy\nrecord type",style="filled"]
        libbusy [label="libbusy.so"]
    }

    ioc -> configMenu [label="uses"]
    ioc -> libautosave [label="uses"]
    ioc -> busy_record [label="needs to know"]
    configMenu -> busy_record [label="uses"]
    busy_record -> libbusy
}
```

This means that apps that use the `autosave` module
might automatically need to link to the `busy` module.

:::{note}
In EPNix's `autosave` packaging,
`busy` isn't included in the dependencies,
because `busy` depends on `autosave`.

Adding `busy` to the dependencies of `autosave` would lead to an infinite loop.
Users of the `autosave` module's "config menu" feature
must manually depend on `busy`.
:::

### General rule

In the EPICS support module world,
if `C` depends on `A`
and an IOC `D` uses `C`,
then there are many cases where `D` needs to import `A.dbd`.

This might happen if `C` uses a record type defined in `A`
or if `D` needs to use IOC shell functions from `A`.

In those cases,
in `C`'s packaging,
it's best to propagate `A`.

  [`asyn` record type]: https://epics-modules.github.io/asyn/asynRecord.html
  ["config menu" feature]: https://epics-modules.github.io/autosave/configMenu.html
  [Leaky abstraction]: https://en.wikipedia.org/wiki/Leaky_abstraction
  [Nixpkgs "Dependency propagation" section]: https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies-propagated
  [Regular Expressions]: https://en.wikipedia.org/wiki/Regular_expression
