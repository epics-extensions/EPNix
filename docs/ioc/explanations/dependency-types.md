# Nix dependency types

:::{seealso}
For a summary on how to add dependencies to an EPICS top,
read the {doc}`../user-guides/dependencies` guide.
:::

:::{important}
When declaring dependencies for other Nix packages:

- Add system library dependencies go into both `buildInputs`.
- Add tools required only during the build process to `nativeBuildInputs`.
- Other attributes exist for more complex cases
:::

When opening the {file}`ioc.nix` in the EPNix IOC template,
you'll find several dependency types
such as:

- `nativeBuildInputs`
- `buildInputs`
- `propagatedBuildInputs`

These dependency types relate to their roles during cross-compilation
and determine whether dependencies should be propagated to dependent packages.

:::{seealso}
The [Nixpkgs "Specifying dependencies" section]
:::

```{toctree}
:glob:

dependency-types/*
```

  [Nixpkgs "Specifying dependencies" section]: https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies
