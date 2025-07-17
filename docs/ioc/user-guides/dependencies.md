# Dependencies

:::{important}
This section focuses on adding dependencies
to EPICS top packages.
Adding dependencies to other types of Nix packages is different
because of how EPICS handles cross-compilation.

For a general explanation,
read {doc}`../explanations/dependency-types`.
:::

## Adding dependencies

:::{tip}
When changing the dependencies of your IOC,
remember to exit and re-enter your development shell
and run `epicsConfigurePhase`.
:::

### Adding EPICS support modules

To add an EPICS support module as a dependency,
add it to `propagatedBuildInputs`:

```{code-block} nix
:caption: {file}`ioc.nix` --- Adding an EPICS support module as a dependency
:emphasize-lines: 9

{
  mkEpicsPackage,
  lib,
  epnix,
}:
mkEpicsPackage {
  # ...

  propagatedBuildInputs = [ epnix.support.StreamDevice ];

  # ...
}
```

### Adding libraries

If your IOC depends on a system library,
add it to both `nativeBuildInputs` and `buildInputs`:

```{code-block} nix
:caption: {file}`ioc.nix` --- Adding a system library as a dependency
:emphasize-lines: 5,10-11

{
  mkEpicsPackage,
  lib,
  epnix,
  libpcre,
}:
mkEpicsPackage {
  # ...

  nativeBuildInputs = [ libpcre ];
  buildInputs = [ libpcre ];

  # ...
}
```

### Adding build tools

If your IOC needs to run a tool during compilation,
add it to `nativeBuildInputs`:

```{code-block} nix
:caption: {file}`ioc.nix` --- Adding a build tool as a dependency
:emphasize-lines: 5,11

{
  mkEpicsPackage,
  lib,
  epnix,
  python3,
}:
mkEpicsPackage {
  # ...

  # If you need to run a Python script during the build
  nativeBuildInputs = [ python3 ];

  # ...
}
```

#### Special cases

If the build tool you want to add generates native code
or searches for system libraries (such as `pkg-config`),
add it to both `depsBuildBuild` and `nativeBuildInputs`:

```{code-block} nix
:caption: {file}`ioc.nix` --- Adding a special build tool as a dependency
:emphasize-lines: 5,11-12

{
  mkEpicsPackage,
  lib,
  epnix,
  pkg-config,
}:
mkEpicsPackage {
  # ...

  # pkg-config searches for system libraries
  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ pkg-config ];

  # ...
}
```

## Listing dependencies

To list all the dependencies of your EPICS top package,
build your top package and run:

```{code-block} bash
:caption: Listing all dependencies of a Nix package
:name: nix-list-deps

nix path-info -rsSh ./result
```

This command shows all the dependencies of your package recursively.

For more information,
see the [`nix path-info` manual].

### Finding a dependency chain

To find why your package depends on a specific dependency,
copy the dependency path shown in the {ref}`nix-list-deps` output
and run:

```{code-block} bash
:caption: Finding a dependency chain with Nix

nix why-depends ./result /nix/store/...-my-dependency
```

For more information,
see the [`nix why-depends` manual].

  [`nix path-info` manual]: https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-path-info
  [`nix why-depends` manual]: https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-why-depends
