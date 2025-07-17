# Packaging the asyn EPICS support module

Sometimes you might want to depend on an EPICS support module
that isn't packaged in EPNix.

In this tutorial,
we'll package the `asyn` support module version `4-45`
step by step.
The `asyn` support module is already packaged in EPNix,
but for this tutorial,
we'll pretend it doesn't exist.

Combined with Nix,
`asyn-4-45` has some packaging quirks
common to some EPICS support modules,
which is why we're using it as an example.

Packaging an EPICS support module is similar
to writing the {file}`ioc.nix` file for an EPNix top.
After all,
both `asyn` and EPNix tops are EPICS tops.

## Prerequisites

Before contributing to EPNix
you need to follow the contributing {doc}`../guides/prerequisites`,
which covers forking EPNix and creating branches.

## Create the package definition

Create a new directory under <source:pkgs/support/by-name/>,
called `my-asyn` for this tutorial.

In this directory,
create a {file}`package.nix` file
with the following template content:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- EPNix support module template

{
  epnixLib,
  mkEpicsPackage,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "TODO";
  version = "TODO";
  varname = "TODO";

  src = TODO;

  inherit local_config_site local_release;

  # For EPICS, native libraries need to be in both
  # nativeBuildInputs and buildInputs
  nativeBuildInputs = [ ];
  buildInputs = [ ];

  # EPICS support modules can only be in propagatedBuildInputs
  propagatedBuildInputs = [ ];

  meta = {
    description = "TODO";
    homepage = "TODO";
    license = TODO;
    maintainers = with epnixLib.maintainers; [ ];
  };
}
```

Remember to `git add` this file.

## Filling out the template

Next,
fill out those TODOs.
Here are the first fields to complete:

:::{describe} pname
The name of the package.
Here,
it's `"my-asyn"`.
:::

:::{describe} version
The version of the package's source code.
Here,
it's `"4-45"`.
:::

:::{describe} varname
The variable name EPNix puts in the {file}`configure/RELEASE.local` file
of dependent packages.
It must be unique across all EPNix packages.

Usually,
it's the package name
in `SCREAMING_SNAKE_CASE`.
In this tutorial,
it's `"MY_ASYN"`.
:::

:::{describe} meta.description
A description of the package.
We recommend using the official description or tagline of the project.
:::

:::{describe} meta.homepage
A URL to the project's homepage.
Here, it's `"https://epics-modules.github.io/master/asyn/"`.
:::

:::{describe} meta.license
The license of the project.

For projects under the "EPICS" license,
set `epnixLib.licenses.epics`.
For other,
more common licenses,
it's {samp}`lib.licenses.{license}`.

A list of available license names can be found
in [Nixpkgs' lib/licenses.nix] file.

In this tutorial,
use `epnixLib.licenses.epics`.
:::

:::{describe} meta.maintainers
A list of people maintaining this package.
In this tutorial,
it can stay empty,
but in a real package,
you must fill it in.
:::

After completing these fields,
your package file should look like this:
```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Filling out the metadata

{
  epnixLib,
  mkEpicsPackage,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "my-asyn";
  version = "4-45";
  varname = "MY_ASYN";

  src = TODO;

  inherit local_config_site local_release;

  # For EPICS, native libraries need to be in both
  # nativeBuildInputs and buildInputs
  nativeBuildInputs = [ ];
  buildInputs = [ ];

  # EPICS support modules can only be in propagatedBuildInputs
  propagatedBuildInputs = [ ];

  meta = {
    description = "Here is a fancy description of my asyn package";
    homepage = "https://epics-modules.github.io/master/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ johndoe ];
  };
}
```

## Fetching the source code

The `asyn` source code is hosted on GitHub
at <https://github.com/epics-modules/asyn>.

`asyn` also tags its releases
in the {samp}`R{X-Y}` format.
For this tutorial,
we're interested in the tag `R4-45`.

For GitHub sources,
Nixpkgs provides a `fetchFromGitHub` function,
which you can use like this:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Fetching the source code
:emphasize-lines: 4,13-18

{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  pname = "my-asyn";
  version = "4-45";
  varname = "MY_ASYN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R4-45";
    hash = "";
  };

  inherit local_config_site local_release;

  # For EPICS, native libraries need to be in both
  # nativeBuildInputs and buildInputs
  nativeBuildInputs = [ ];
  buildInputs = [ ];

  # EPICS support modules can only be in propagatedBuildInputs
  propagatedBuildInputs = [ ];

  meta = {
    description = "Here is a fancy description of my asyn package";
    homepage = "https://epics-modules.github.io/master/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ johndoe ];
  };
}
```

:::{note}
You might notice that the `hash` field is empty.

This is a common development pattern in Nix:
when you don't know the hash ahead of time,
set it to the empty string.
When you build this package,
Nix will tell you what the hash should be.
:::

Be sure to `git add` this newly added file,
and build your package with:

```{code-block} bash
:caption: Building your `my-asyn` EPICS support package
:name: build-my-asyn

nix build -L ".#support/my-asyn"
```

You should see Nix fail to build the package,
with an error like this:

```{code-block}
:emphasize-lines: 10-12

warning: Git tree '/path/to/EPNix' is dirty
warning: found empty hash, assuming 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
source>
source> trying https://github.com/epics-modules/asyn/archive/refs/tags/R4-45.tar.gz
source>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
source>                                  Dload  Upload   Total   Spent    Left  Speed
source>   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
source> 100 1453k    0 1453k    0     0  1563k      0 --:--:-- --:--:-- --:--:-- 15.0M
source> unpacking source archive /build/download.tar.gz
error: hash mismatch in fixed-output derivation '/nix/store/crhdrjqciq1n84s3azi7gjz49w16mxkz-source.drv':
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=
error: Cannot build '/nix/store/rqa8lfsx8qrxd53g7sa1w0rxvhgba9g3-my-asyn-4-45.drv'.
       Reason: 1 dependency failed.
       Output paths:
         /nix/store/jmrig6qsh0ygy6q45jg17y9jjyq8jsx6-my-asyn-4-45
```

Here,
Nix downloads the `asyn` source code tarball
and fails to validate the hash.
Thankfully,
Nix tells you the correct hash,
so you can update your package:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Updating the source hash
:emphasize-lines: 7

  # ...

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R4-45";
    hash = "sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=";
  };

  # ...
```

## Adding dependencies

To determine what a package depends on,
it's best to consult its documentation
if available.
If the documentation doesn't provide this information,
you can inspect the package's source code
and read build errors
to identify dependencies.

For `asyn-4-45`,
not all dependencies are documented,
so we'll need to investigate.

### Dependency types

In the current version of your package,
you can notice several types of dependencies,
such as `nativeBuildInputs` and `propagatedBuildInputs`.

These dependency types relate to their roles during cross-compilation
and determine whether dependencies should be propagated to dependent packages.

For a summary on how to add dependencies to an EPICS top,
read the {doc}`../../ioc/user-guides/dependencies` guide.
For a detailed explanation of these dependency types,
read {doc}`../../ioc/explanations/dependency-types`.

### Adding EPICS dependencies

To find EPICS dependencies
if unspecified in the documentation,
you can look at [`asyn`'s {file}`configure/RELEASE`] file.

:::{important}
Make sure to inspect the source code from the `R4-45` version.
:::

From this source file,
we see that `asyn` depends on `epics-base`
which `mkEpicsPackage` includes by default.

It also optionally depends on `ipac`,
`sncseq` from the `seq` package,
`calc`,
and transitively on `sscan`.
You don't need to specify transitive dependencies,
as they're automatically propagated.

In EPNix we try to include optional dependencies by default,
so we'll add them to our package.
Since EPICS dependencies go into `propagatedBuildInputs`,
edit your package file as follows:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Adding EPICS dependencies
:emphasize-lines: 5-7,14-18

{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  calc,
  ipac,
  seq,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  # ...

  propagatedBuildInputs = [
    calc
    ipac
    seq
  ];

  # ...
}
```

If you {ref}`try to build it <build-my-asyn>`
you'll see at the beginning of the `my-asyn` build logs:

```{code-block}
:caption: EPNix adding EPICS dependencies during the build
:emphasize-lines: 13-17

my-asyn> Running phase: configurePhase
my-asyn> ==============================
my-asyn> CONFIG_SITE.local
my-asyn> ------------------------------
my-asyn> GENVERSIONDEFAULT="EPNix"
my-asyn> GNU_DIR="/var/empty"
my-asyn>
my-asyn> ==============================
my-asyn> RELEASE.local
my-asyn> ------------------------------
my-asyn> undefine SUPPORT
my-asyn>
my-asyn> EPICS_BASE=/nix/store/<...>-epics-base-7.0.9
my-asyn> CALC=/nix/store/<...>-calc-3-7-5
my-asyn> SSCAN=/nix/store/<...>-sscan-2-11-6
my-asyn> IPAC=/nix/store/<...>-ipac-2.16
my-asyn> SNCSEQ=/nix/store/<...>-seq-2.2.9
my-asyn> ------------------------------
```

These are the lines added to `CONFIG_SITE.local` and `RELEASE.local`.
We see that EPNix added the path to the EPICS dependencies we specified.
The package still doesn't build,
but it's progress.

### Adding build tools

The current version of our `my-asyn` package doesn't build,
due to this error:

```
my-asyn> /nix/store/<...>-bash-5.2p37/bin/bash: line 1: rpcgen: command not found
```

The `asyn` build system tries to run the `rpcgen` command,
but couldn't find it.

To determine which package provides the `rpcgen` command,
you can search for it online
or use a package manager.

Using Nix,
you can use the `nix-index` tool to find it:

```{code-block} bash
# Install the 'nix-index' tool for your current user
nix-env -iA nixpkgs.nix-index
# Update the index database
nix-index
# Search for the given file
nix-locate --top-level /bin/rpcgen
```

The `nix-locate` command returns only one result: `rpcsvc-proto`.
As explained in <project:#dependency-types>,
for EPICS packages,
build tools go into `nativeBuildInputs`.
Edit your package as follows:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Adding the `rpcsvc-proto` build tool
:emphasize-lines: 5,15

{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  rpcsvc-proto,
  calc,
  ipac,
  seq,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  # ...

  nativeBuildInputs = [ rpcsvc-proto ];

  # ...
}
```

If you {ref}`try to build <build-my-asyn>` the package,
you should see the build progress further.

### Adding native dependencies

The current version of our `my-asyn` package still doesn't build
due to this error:

```
my-asyn> In file included from vxi11core_xdr.c:6:
my-asyn> vxi11core.h:9:10: fatal error: rpc/rpc.h: No such file or directory
my-asyn>     9 | #include <rpc/rpc.h>
my-asyn>       |          ^~~~~~~~~~~
my-asyn> compilation terminated.
```

This tells us that there's a C library that `asyn` can't find,
specifically,
a library that provides the {file}`rpc/rpc.h` include file,
but the build system didn't have this file in its search path.

The first step to fixing this build failure is adding this library
to the package's dependencies.

To find which library provides this file comes from,
you can:

- Search for the filename online
- Use the package manager to search for the file
- Inspect the `asyn` source code

#### Searching by using the package manager

You can again use the `nix-index` tool
to search for files contained in Nixpkgs packages:

```{code-block} bash
nix-locate --top-level /rpc/rpc.h
```

The `nix-locate` command returns several packages.
Example output:

```
python313Packages.torchWithVulkan.dev    164 r /nix/store/<...>-python3.13-torch-2.7.0-dev/include/torch/csrc/distributed/rpc/rpc.h
python313Packages.torch.dev              164 r /nix/store/<...>-python3.13-torch-2.7.0-dev/include/torch/csrc/distributed/rpc/rpc.h
python313Packages.torch-no-triton.dev    164 r /nix/store/<...>-python3.13-torch-2.7.0-dev/include/torch/csrc/distributed/rpc/rpc.h
<...>
python312Packages.autopxd2.out            55 r /nix/store/<...>-python3.12-python-autopxd2-2.5.0/lib/python3.12/site-packages/autopxd/stubs/darwin-include/rpc/rpc.h
ntirpc.dev                             3,613 r /nix/store/<...>-ntirpc-6.3-dev/include/ntirpc/rpc/rpc.h
livekit-libwebrtc.dev                  7,096 r /nix/store/<...>-livekit-libwebrtc-125-unstable-2025-03-24-dev/include/third_party/perfetto/src/trace_processor/rpc/rpc.h
libtirpc.dev                           4,130 r /nix/store/<...>-libtirpc-1.3.6-dev/include/tirpc/rpc/rpc.h
libtorch-bin.dev                         164 r /nix/store/<...>-libtorch-2.5.0-dev/include/torch/csrc/distributed/rpc/rpc.h
```

We can ignore the Python packages,
since we're looking for a C library.
Searching these packages
by using [Nixpkgs' package search],
we can also eliminate other packages:

- `libtorch` is for machine learning
- `livekit` is for [WebRTC]

That leaves `ntirpc` and `libtirpc` as candidates.

Reading the README of `ntirpc`,
we see references to `libtirpc`,
which suggests that `ntirpc` is a fork of `libtirpc`.
Therefore `libtirpc` is probably the correct library.

#### Searching the source code

Another way to find this library is by inspecting the `asyn` source code.

First,
try searching for "RPC" in `asyn`'s Makefiles.
Clone the [`asyn` repository]
and switch to the `R4-45` version:

```{code-block} bash
:caption: Cloning the `asyn` source code.

git clone https://github.com/epics-modules/asyn
git switch -d R4-45
```

From the top directory of the `asyn` source code,
run:

```{code-block} bash
:caption: Search for RPC in every {file}`Makefile`

grep rpc -i --include=Makefile -R .
```

From the results,
you will see these lines:

```{code-block}
:caption: RPC search results
:emphasize-lines: 1,3-7,13-15
:name: rpc-search

./asyn/Makefile:USR_INCLUDES_cygwin32 += -I/usr/include/tirpc
./asyn/Makefile:asyn_SYS_LIBS_cygwin32 = $(CYGWIN_RPC_LIB)
./asyn/Makefile:# Some linux systems moved RPC related symbols to libtirpc
./asyn/Makefile:# Define TIRPC in configure/CONFIG_SITE in this case
./asyn/Makefile:ifeq ($(TIRPC),YES)
./asyn/Makefile:  USR_INCLUDES_Linux += -I/usr/include/tirpc
./asyn/Makefile:  asyn_SYS_LIBS_Linux += tirpc
./asyn/Makefile:% : ../vxi11/rpc/%
./asyn/Makefile:RPCGEN_FLAGS_darwin = -C
./asyn/Makefile:RPCGEN_FLAGS_solaris = -M
./asyn/Makefile:%.h %_xdr.c: ../vxi11/%.rpcl
./asyn/Makefile:        rpcgen $(RPCGEN_FLAGS_$(OS_CLASS)) $*.rpcl
./testGpibApp/src/Makefile:ifeq ($(TIRPC),YES)
./testGpibApp/src/Makefile:  USR_INCLUDES += -I/usr/include/tirpc
./testGpibApp/src/Makefile:  testGpib_SYS_LIBS += tirpc
./testGpibApp/src/Makefile:SYS_PROD_LIBS_cygwin32 += $(CYGWIN_RPC_LIB)
```

All highlighted lines reference `tirpc` or `libtirpc`.
This confirms the `libtirpc` is the package we want.

Another approach would be searching for the string `INCLUDES`,
since variables for modifying the include path follow the pattern {samp}`{xxx}_INCLUDES`,
according to [EPICS' Build facility specifications].

#### Editing the package

Now that we've found the dependency,
edit your package.
As explained in <project:#dependency-types>,
for EPICS packages
native libraries go into both `nativeBuildInputs` and `buildInputs`.

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Adding the `libtirpc` library
:emphasize-lines: 6,16-17

{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  rpcsvc-proto,
  libtirpc,
  calc,
  ipac,
  seq,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  # ...

  nativeBuildInputs = [ rpcsvc-proto libtirpc ];
  buildInputs = [ libtirpc ];

  # ...
}
```

If you {ref}`try to build <build-my-asyn>` the package,
you'll see that although we added `libtirpc` as a dependency,
the error wasn't fixed.

## Changing the `CONFIG_SITE`

One reason the package still doesn't compile can be found in `asyn`'s {file}`configure/CONFIG_SITE` file,
specifically these lines:

```{code-block} make
:caption: {file}`configure/CONFIG_SITE` --- `asyn`'s warning about `libtirpc`

# Some linux systems moved RPC related symbols to libtirpc
# To enable linking against this library, uncomment the following line
# TIRPC=YES
```

Since we had to add `libtirpc` to the dependencies,
the comment applies.

Instead of uncommenting the file,
we'll write `TIRPC=YES` to {file}`configure/CONFIG_SITE.local`
using the special `local_config_site` argument of `mkEpicsPackage`:

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Setting `TIRPC=YES` in `asyn`'s {file}`configure/CONFIG_SITE.local`
:emphasize-lines: 6-8

# ...
mkEpicsPackage {
  # ...

  inherit local_release;
  local_config_site = local_config_site // {
    TIRPC = "YES";
  };

  # ...
}
```

You can see EPNix adding the variable
at the beginning of the `my-asyn` build logs:

```{code-block}
:caption: EPNix adding `TIRPC=YES` during the build
:emphasize-lines: 6

my-asyn> ==============================
my-asyn> CONFIG_SITE.local
my-asyn> ------------------------------
my-asyn> GENVERSIONDEFAULT="EPNix"
my-asyn> GNU_DIR="/var/empty"
my-asyn> TIRPC=YES
my-asyn>
my-asyn> ==============================
```

## Patching the source code

The error `rpc/rpc.h: No such file or directory` is still present
when building our package.

This error comes from how `libtirpc` is added to the include search path.

From our {ref}`rpc-search` in `asyn`'s source code,
we see that the path {file}`/usr/include/tirpc` is added as-is.
This suggests that `libtirpc` must be installed globally,
at the root directory of your system.
However,
this won't work for Nix packages:

- Nix builds packages in a sandbox,
  preventing builds from accessing global system files.
  This ensures you don't forget specifying dependencies.
- Nix installs packages in directories
  such as {file}`/nix/store/{<...>-libtirpc-1.3.6-dev}`,
  not {file}`/usr`.

We need to change `asyn`'s source code
so its build system can find `libtirpc`.

### Making changes

To locate `libtirpc`,
we'll use [`pkg-config`],
which is the de facto standard
in the C/C++ world
for finding libraries.

If you haven't already,
clone the [`asyn` repository]
and switch to the `R4-45` version:

```{code-block} bash
:caption: Cloning the `asyn` source code.

git clone https://github.com/epics-modules/asyn
git switch -d R4-45
```

In the `asyn` source code,
replace every instance of `-I/usr/include/tirpc`
with a call to `pkg-config --cflags`:

```{code-block} make
:caption: Replacing hardcoded includes with calls to `pkg-config`

# Replace these kinds of lines:
USR_INCLUDES_Linux += -I/usr/include/tirpc
# With:
USR_INCLUDES_Linux += `pkg-config --cflags libtirpc`
```

### Creating the patch

After you have made these changes
in every relevant {file}`Makefile`,
generate a patch file:

```{code-block} bash
:caption: Generating a patch file with your `asyn` changes

git diff --patch > use-pkg-config.patch
```

Copy this file into EPNix,
in the same directory as your package,
at {file}`pkgs/support/by-name/my-asyn/use-pkg-config.patch`.

Remember to `git add` this file.

### Using the patch

Next,
we need to use that patch in the package
and add `pkg-config` to the package's dependencies.

Since `pkg-config` is a tool run during the build process,
it goes into `nativeBuildInputs`.

```{code-block} nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Importing the patch
:emphasize-lines: 5,19,23

{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  calc,
  ipac,
  seq,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage {
  # ...

  src = ...;

  patches = [ ./use-pkg-config.patch ];

  # ...

  nativeBuildInputs = [ pkg-config rpcsvc-proto libtirpc ];

  # ...
}
```

With these changes,
the package should now build.

:::{tip}
If you want to try the `pkg-config` command yourself,
you can enter the `my-asyn` development shell
just as you would for any EPNix IOC:

```{code-block} bash
:caption: Manually trying the `pkg-config` command

nix develop '.#support/my-asyn'
pkg-config --cflags libtirpc
```
:::

## Complete example

```{literalinclude} ./packaging-asyn/my-asyn/package.nix
:caption: {file}`pkgs/support/by-name/{my-asyn}/package.nix` --- Complete example
:language: nix
```

```{literalinclude} ./packaging-asyn/my-asyn/use-pkg-config.patch
:caption: {file}`pkgs/support/by-name/{my-asyn}/use-pkg-config.patch` --- Complete example
:language: diff
```

## External resources

Here are some resources
to learn more about Nix packaging:

- Other support modules in EPNix,
  in the <source:pkgs/support/by-name> folder.
- The [Nix.dev Packaging existing software] tutorial
- The [Nixpkgs manual]

  [`asyn` repository]: https://github.com/epics-modules/asyn
  [`asyn`'s {file}`configure/RELEASE`]: https://github.com/epics-modules/asyn/blob/R4-45/configure/RELEASE
  [`pkg-config`]: https://www.freedesktop.org/wiki/Software/pkg-config/
  [EPICS' Build facility specifications]: https://docs.epics-controls.org/en/latest/build-system/specifications.html?highlight=INCLUDES#compiler-flags
  [epnix github repository]: https://github.com/epics-extensions/EPNix/
  [Nix.dev Packaging existing software]: https://nix.dev/tutorials/packaging-existing-software
  [Nixpkgs manual]: https://nixos.org/manual/nixpkgs/stable/
  [Nixpkgs' lib/licenses.nix]: https://github.com/NixOS/nixpkgs/blob/master/lib/licenses.nix
  [Nixpkgs' package search]: https://search.nixos.org/packages
  [WebRTC]: https://en.wikipedia.org/wiki/WebRTC
  [working with forks]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks
