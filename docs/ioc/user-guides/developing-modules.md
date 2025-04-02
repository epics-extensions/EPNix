# Developing support modules

% TODO: rewrite, not clear enough, probably move most of it into day-to-day tutorial

It can happen that one needs to hack on an EPICS support module,
while also developing an IOC.
This might be to develop and test the support module,
or to patch and test the support module.

This is where Nix’s reproducibility guarantees might seem to be in the way:
dependencies are taken from the `/nix/store` instead of your local repository.
You can add it as a flake input instead,
but that requires to run `nix flake lock --update-input mySupport` on each modification, etc.

To bypass these constraints,
there are several mechanisms that let you to temporarily weaken these constraints for development purposes.

## Packaging a starter module

First, clone the EPNix repository, and package your support module.

% You can look at the `Packaging modules`_ (TODO) guide,
% this doesn’t even have to compile yet,
% but you need to specify the dependencies of your support module.
%
% .. _Packaging modules: ../developer-guides/packaging-modules.md

## Hacking on your module

From the directory containing the source code of your support module, run:

```bash
nix develop "/path/to/local/epnix#support/mySupport"
# Then, inside the development shell
dontUnpack=true
genericBuild
```

This will put the result of your compilation under `outputs/out`.
If you make modifications to your support module,
run `buildPhase` from the same development shell to recompile it.

## Using it on your EPICS top

Before trying to compile your top,
make sure that your support module is in the build environment:

```{code-block} nix
:caption: {file}`ioc.nix` --- Adding your support module to the build environment

propagatedBuildInputs = [
  epnix.support.mySupport
];
```

Now that the support module is compiled and installed in a local directory,
you can ask Nix to use it as is.
This can be done by running this command from your EPICS top directory:

```bash
nix develop \
  --override-input epnix '/path/to/local/epnix' \
  --redirect '/path/to/local/epnix#support/mySupport' '/path/to/mySupport/outputs/out'
# Then, normal hacking on an EPICS top...
```

The `--override-input` option instructs Nix to use your local EPNix fork
instead of the one hosted on GitHub.
Use this option to override flake inputs.

The `--redirect` option instructs Nix to use your local directory for your support module,
instead of a module installed in the `/nix/store`.
Use this option to override individual packages.

----

With this setup,
you can hack and compile your support module,
and the changes will be directly visible to your top.
This enables you to hack on both project at the same time,
each on their own development shell.

One question one may ask:

> What’s the difference between
> running the complex `nix develop` command
> and just putting `/path/to/mySupport/outputs/out` into `RELEASE.local`?

One thing that the complex `nix develop` command does correctly,
is replacing *everything* that would have been `/nix/store/...-mySupport../` into your development shell.
This includes the `RELEASE.local` file,
but this may not be the only thing:

For example,
if you’re hacking on the `seq` support module,
not only will it put the path to your local `seq` module into `RELEASE.local`,
but it will also put some `seq` specific programs into your `$PATH`, like the `snc` utility.
These programs will be those from your local build,
not the ones coming from the EPNix repository.
