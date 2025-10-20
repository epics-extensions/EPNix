# Dependency updates

## Updating your dependencies

With EPNix, your dependencies are locked to a specific version
to ensure reproducibility.

This is done by locking your flake inputs to a specific Git revision
in the {file}`flake.lock` file.

The `epnix` flake input has most of your dependencies,
such as {nix:pkg}`epnix.epics-base`,
most support modules,
system libraries,
and build tools.

You can add other flake inputs
to depend on software and source code not packaged inside EPNix.
You will need to manage the updates of those flake inputs.

:::{tip}
After changing your flake inputs,
make sure you can rebuild your IOC with `nix build -L`,
and re-generate your {file}`RELEASE.local` file
by running `epicsConfigurePhase`
inside a development shell.
:::

### Updating EPNix

To update them, update your EPNix flake input:

```{code-block} bash
:caption: Updating the `epnix` flake input

nix flake update epnix
```

You can also create a Git commit automatically by running:

```{code-block} bash
:caption: Updating the `epnix` flake input and creating a Git commit

nix flake update epnix --commit-lock-file
```

### Updating specific flake inputs

To update specific flake inputs,
run:

```{code-block} bash
:caption: Updating the `epnix` flake input

nix flake update <flake input names...>
```

You can also pass the option `--commit-lock-file`
to create a Git commit automatically.

### Updating all flake inputs

To update all inputs in your {file}`flake.nix` and {file}`flake.lock` files,
run:

```{code-block} bash
:caption: Updating the `epnix` flake input

nix flake update
```

You can also pass the option `--commit-lock-file`
to create a Git commit automatically.

## Restoring dependencies to an earlier version

To rollback the dependencies as they were in an earlier version of your project,
rollback the {file}`flake.lock` using Git.
