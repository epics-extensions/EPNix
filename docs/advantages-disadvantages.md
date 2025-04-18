# Advantages / disadvantages

## Advantages

Leveraging the Nix package manager provides several advantages
compared to packaging EPICS the traditional way.

Some of those advantages are explained on the [NixOS website].

### Complete dependencies

Your EPICS application includes the complete set of dependencies,
which means you can deploy your application
without needing to install any dependency
on the target machine (except for Nix itself).

### Locked dependencies

The version of your dependencies are locked,
updated manually,
and traced in your `flake.lock` file.

Combined with code versioning,
you can build your project with the same environment years later.

You can also use that feature
to roll back to any earlier version.

### Dependency traceability

You can also figure out the exact version
of each of your build or runtime dependency.
This can be useful
to comply with supply chain security requirements.

### Development shell

Provides you with a set of tools adapted to your project,
no matter what you have installed on your machine.

### Declarative configurations

Nix is used as a declarative language
for specifying what you want in your application,
in your development environment,
or how to configure a NixOS Linux system.

### Integration tests

Write tests by using the NixOS test framework.
It starts clusters of NixOS virtual machines,
containing applications
that you want to test.
These machines are then controllable and testable through a Python API.

### Offline deployments

NixOS makes it possible to deploy to machines
that don't have an global internet connection.

### Vendor-agnostic continuous integration

Because Nix handles dependencies and building,
most CI actions are a two step process:

-   installing Nix in the CI
-   running the `nix build` or `nix run` command

This makes it possible to run those CI actions locally,
on any developer machine.
This also makes it easier to migrate to a different CI system,
if needed.

### Distributed builds

Nix can build packages on many remote machines.
Examine the Nix documentation on [Remote builds] for more information.

### Cache server

You can deploy a Nix cache server in your infrastructure,
so that users can download pre-built versions of any software packaged with Nix,
without having to compile them.

## Disadvantages

### Nix learning curve

Nix has a well-known steep learning curve,
and uneven documentation.

Make sure to experiment with the Nix ecosystem first,
before deploying Nix-based packages into production.

You can use EPNix for non-critical tasks,
such as:

-   defining development shells,
-   quickly running a package,
    for example Phoebus, or a `softIoc`.
-   running tests

### Strict packaging

Nix is strict when it comes to packages that are straightforward to package:
most Nix build packages in a sandbox
that only has specified dependencies,
and with no internet access.

Nix also assumes that builds are reproducible
(see [Reproducible builds]).

This strictness is part of what makes Nix features possible,
but it also means that some software is going to be more difficult to package than others.

### Non-uniformity

Depending on how you declare your IOCs and NixOS machines,
your deployments can have different versions of software dependencies.

For example,
different deployed IOCs can use different versions of StreamDevice, or asyn.
This is technically fine
if the EPICS Channel Access or PV Access protocol stay compatible with earlier version.

But for deployments such as Phoebus services,
or Archiver Appliance,
which uses HTTP APIs,
it's your responsibility to architecture your Nix and NixOS deployments
so that the set of deployed software are compatible
between each other.

  [NixOS website]: https://nixos.org/
  [Reproducible builds]: https://reproducible-builds.org/
  [Remote builds]: https://nix.dev/manual/nix/stable/advanced-topics/distributed-builds
