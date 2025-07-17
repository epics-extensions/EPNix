# Cross-compilation

:::{seealso}
- The [nix.dev "Cross compilation" tutorial]
- The [Nixpkgs "Specifying dependencies" section]
- The [Nixpkgs "Cross-compilation" section]
:::

Cross-compilation is the process of compiling a program for a platform
different from the build platform.
This is the opposite of "native compilation,"
where you compile for the same platform as your build platform.

For example,
your development machine might run Linux with an `x86_64` CPU
and target a Raspberry Pi,
which also runs Linux but uses an `aarch64` CPU.
Or you might be developing on a Mac M1
and targeting a Linux embedded board with a `powerpc64` CPU.

In these cases,
building a package differs from native compilation,
especially when handling dependencies:

- The compiler is different
  because it targets a different platform.
  We call these compilers "cross-compilers."
- The package most likely expects system libraries to be cross-compiled
  since it will use these libraries at runtime.
- However,
  build systems (`cmake`, `meson`),
  build tools (`pkg-config`),
  or even interpreters (`bash`, `python`) for running build scripts
  need to run on the build platform.

We need a consistent way to handle these different types of dependencies.

## General concepts

### Target triples

Before compiling for a different platform,
we need a way to name them.

The most common convention is called the "target triple."
It generally,
but not always,
follows the convention {samp}`{machine}-{vendor}-{operatingsystem}`.

Here is a list of example target triples:

| Common name        | Target triple          |
|--------------------|------------------------|
| Linux on `x86_64`  | `x86_64-unknown-linux` |
| macOS on `x86_64`  | `x86_64-apple-darwin`  |
| macOS on `aarch64` | `aarch64-apple-darwin` |

There are many details,
exceptions,
ambiguities,
and inconsistencies in these naming conventions,
but they aren't relevant to this article.

:::{seealso}
The [What the Hell Is a Target Triple?] blog post from Miguel Young de la Sota
goes much more in-depth about the history
and logic (or lack thereof)
of target triple names.
:::

:::{caution}
This naming convention for architecture is most common in the software world,
used by Nix, `gcc`, `autotools`, `LLVM`, and others,
but EPICS uses a different convention.

EPICS platforms generally follow the form {samp}`{operatingsystem}-{machine}`,
for example `linux-x86_64` or `darwin-aarch64`.
:::

### Platform types

Next,
we need to define names for our platform types.

The `autotools` convention used by Nix defines three platforms:

Build platform:
:   The platform that builds the software.

    When cross-compiling,
    every package is built on the build platform,
    so it stays the same
    for every package in the dependency tree.

Host platform:
:   The platform that runs the compiled software.

    When we say we're cross-compiling for Raspberry Pi,
    Raspberry Pi is the host platform.

Target platform:
:   When a program generates native code,
    a third platform comes into play.

    For example,
    `gcc` might be compiled on `x86_64-linux`,
    run on `aarch64-apple-darwin`,
    but generate code for Raspberry Pi.

    In this example,
    `x86_64-linux` is the build platform of `gcc`,
    `aarch64-apple-darwin` is the host platform,
    and Raspberry Pi is the target platform.

    The same applies to programs that search for native libraries,
    such as `pkg-config`.

In most cases,
we only need to care about the build platform and the host platform
when specifying dependencies.

When you have special cases,
such as a build system that builds a build tool and uses it,
that's when you need to care about target platforms.

:::{caution}
EPICS uses a different convention for naming platforms.
Since EPICS projects don't generally produce programs that generate native code,
the concept of "target platform" doesn't exist.
Instead,
EPICS uses the following names:

:Host architecture:
    The platform that builds the software,
    what Nix calls the "Build platform."
:Target architecture:
    The platform that runs the compiled software,
    what Nix calls the "Host platform."

In this article,
we use the Nix platform names.
:::

### Nix cross-compilation dependency types

When you specify dependencies in your Nix package,
you can choose between `buildInputs`, `nativeBuildInputs`, and other options.

This choice determines the relationship between the dependency's host and target platforms
compared to your own package's platforms.

In the following section,
we'll examine real package examples.

## Most packages

The first example is the `open62541` library,
which is used by the EPICS {nix:pkg}`epnix.support.opcua` support module.

This package requires:

- GCC as the C compiler
- CMake as the build system
- `pkg-config` to locate system libraries
- Python to run a script during the build
- the OpenSSL library to implement [OPC-UA] protocol encryption

If we're cross-compiling `open62541`
from a Linux `x86_64` development machine
for a Raspberry Pi,
the platforms of these dependencies are as follows:

:::{table} Platform types of the `open62541` dependencies

|              | `x86_64-linux` | Raspberry Pi |
|--------------|----------------|--------------|
| `gcc`        | built, runs    | targets      |
| `pkg-config` | built, runs    | targets      |
| `cmake`      | built, runs    |              |
| `python`     | built, runs    |              |
| `openssl`    | built          | runs         |
:::

In this example,
the build platform for `open62541` is `x86_64-linux`,
and the host platform is the Raspberry Pi.

`open62541` doesn't generate native code,
so we don't care about the target platform.

We can see that there are three types of dependencies:

- `gcc` and `pkg-config`
  - `open62541` uses `gcc` to generate code for Raspberry Pi,
    so it needs to run on the build platform
    and target the host platform
  - `open62541` uses `pkg-config` to search for libraries compiled for Raspberry Pi,
    so it also needs to run on the build platform
    and target the host platform
- `cmake` and `python` are run during the build,
  so they need to run on the build platform,
  and we don't care about a target platform
- `openssl` is going to run on Raspberry Pi,
  so it needs to run on the host platform,
  and we don't care about a target platform

Since we don't always consider the target platform,
these dependencies can be categorized into two types:

- Dependencies that have the same host platform as the package
- Dependencies that run on the build platform and target the host platform

The first type belongs in `buildInputs`,
and the second belongs in `nativeBuildInputs`.

For `open62541`,
we would have:

```{code-block} nix
:caption: Dependency definitions of the `open62541` package

{
  stdenv,
  cmake,
  pkg-config,
  python3,
  openssl,
  # ...
}:
stdenv.mkDerivation {
  # ...

  # No need to include gcc,
  # it's included by default.
  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [ openssl ];

  # ...
}
```

## EPICS tops

### Double compilation

When cross-compiling an EPICS top,
EPICS does something unusual:
it compiles the top twice:

1. For the build platform (which EPICS calls the host architecture)
2. For the host platform (which EPICS calls the target architecture)

When compiling the `opcua` support module for Raspberry Pi,
for example,
the output is as follows:

```{code-block}
:caption: Cross-compiled `opcua` package

/nix/store/...-opcua-aarch64-unknown-linux-gnu-0.10.0
├── bin
│   ├── linux-aarch64
│   │   └── opcuaIoc
│   └── linux-x86_64
│       └── opcuaIoc
├── lib
│   ├── linux-aarch64
│   │   ├── libopcua.a
│   │   └── libopcua.so
│   └── linux-x86_64
│       ├── libopcua.a
│       └── libopcua.so
├── configure
│   ├── RELEASE
│   └── RELEASE.local
└── ...
```

You can see there are two {file}`opcuaIoc` binaries
and two `libopcua.so` libraries,
one for each of the build and host platforms.

This means that during the build process,
the sources were natively compiled
and then cross-compiled.

### Impact on dependencies

Because the sources are compiled twice
for two different architectures,
the dependencies are affected.

For example,
when cross-compiling the `opcua` EPICS support module,
the package requires two different compilers:

1. A compiler that targets the build platform
2. A compiler that targets the host platform

The same applies to system libraries.
The natively compiled `opcua` depends on the `open62541` library.
However,
the cross-compiled version of `opcua` depends on two instances of the `open62541` library:

1. An `open62541` that runs on the build platform
2. An `open62541` that runs on the host platform

:::{table} Platform types of the cross-compiled `StreamDevice` dependencies

|                      | `x86_64-linux`       | Raspberry Pi |
|----------------------|----------------------|--------------|
| `gcc`{sub}`1`        | built, runs, targets |              |
| `gcc`{sub}`2`        | built, runs          | targets      |
| `pkg-config`{sub}`1` | built, runs, targets |              |
| `pkg-config`{sub}`2` | built, runs          | targets      |
| `open62541`{sub}`1`  | built, runs          |              |
| `open62541`{sub}`2`  | built                | runs         |
:::

In this example,
the build platform of `opcua` is `x86_64-linux`,
and the host platform is the Raspberry Pi.

Because `opcua` is an EPICS support module,
it can also be run on its build platform.

Compared to the `open62541` example in the <project:#most-packages> section,
we now have some duplicate dependencies
across different platforms.
There's also a new type of dependency,
represented by `gcc`{sub}`1` and `pkg-config`{sub}`1`.

- `gcc`{sub}`2`, `pkg-config`{sub}`2`, and `open62541`{sub}`1` belong in `nativeBuildInputs`
- `open62541`{sub}`2` belongs in `buildInputs`

However,
`gcc`{sub}`1` doesn't belong in `nativeBuildInputs`
since that would target the Raspberry Pi.
The same applies to `pkg-config`{sub}`1`,
which would search for Raspberry Pi libraries.
For these packages,
we need a new type of dependency
that specifies that they run on the build platform
*and* target the build platform.

These dependencies belong in `depsBuildBuild`.

The first `Build` of this attribute refers to the dependency's host platform,
which is the package's `Build` platform,
that is, it will run on the `Build` platform.

The second `Build` of this attribute refers to the dependency's target platform,
which is the package's `Build` platform,
that is, it will generate code for the `Build` platform.

For our `opcua` example,
we have:

```{code-block} nix
:caption: Dependency definitions of the `opcua` support module package

{
  mkEpicsPackage,
  pkg-config,
  open62541,
  openssl,
  # ...
}:
mkEpicsPackage {
  # ...

  # No need to include gcc,
  # it's included in depsBuildBuild by default in mkEpicsPackage
  depsBuildBuild = [ pkg-config ];

  # No need to include gcc,
  # it's included by default.
  nativeBuildInputs = [
    pkg-config
    open62541
  ];
  buildInputs = [ open62541 ];

  # ...
}
```

:::{note}
There are other types of dependencies
in the form {samp}`deps{X}{Y}`,
where *X* specifies the host platform of the dependency
and *Y* specifies the target platform.

Here are some examples of rarely used attributes:

- `depsHostHost` refers to dependencies
  that must run on the package's **host** platform
  and generate native code for the package's **host** platform.
- `depsBuildTarget` refers to dependencies
  that must run on the package's **build** platform
  and generate native code for the package's **target** platform.

The `buildInputs` attribute could have been named `depsHostTarget`,
and `nativeBuildInputs` could have been named `depsBuildHost`.

For each type of dependency,
there's a "propagated" variant.
See {doc}`propagation` for an explanation.

See the [Nixpkgs "Variables specifying dependencies" section] for a complete list of these attributes.
:::

### General rule

:::{note}
These rules are specific to packaging EPICS tops.
:::

- System libraries belong in both `nativeBuildInputs` and `buildInputs`.

- If build tools generate native code or search for system libraries,
  they belong in both `depsBuildBuild` and `nativeBuildInputs`.
  If not,
  they belong in `nativeBuildInputs`.

- EPICS dependencies belong in `propagatedBuildInputs`.
  See {doc}`propagation`.

### Drawbacks with Nix

One consequence of this double compilation is dependency duplication.
Cross-compiled EPICS tops have both duplicated build-time and runtime dependencies.

Nix determines runtime dependencies straightforwardly:
if Nix finds a reference to a build dependency in the package output,
that dependency becomes a runtime dependency.

In our `opcua` example,
the package depends on two different `open62541` packages
at runtime:
one for `x86_64-linux` and one for Raspberry Pi.
Deploying this cross-compiled `opcua` package
requires deploying both `open62541` libraries,
increasing disk usage.

Cross-compilation often targets embedded systems,
which typically have constrained disk space.

This double-compilation mechanism is therefore problematic with Nix
but may change in the future.

  [Nixpkgs "Cross-compilation" section]: https://nixos.org/manual/nixpkgs/stable/#chap-cross
  [Nixpkgs "Specifying dependencies" section]: https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies
  [Nixpkgs "Variables specifying dependencies" section]: https://nixos.org/manual/nixpkgs/stable/#variables-specifying-dependencies
  [OPC-UA]: https://en.wikipedia.org/wiki/OPC_Unified_Architecture
  [What the Hell Is a Target Triple?]: https://mcyoung.xyz/2025/04/14/target-triples/
  [nix.dev "Cross compilation" tutorial]: https://nix.dev/tutorials/cross-compilation
