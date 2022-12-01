# Developing modules

It can happen that one needs to hack on an EPICS support module, while also
developing an App. This might be to develop and test the support module, or to
patch and test the support module, etc.

This is where Nix's reproducibility guarantees might seem to be in the way:
dependencies are for from the `/nix/store` instead of your local repository,
adding it as a flake input requires to run `nix flake lock --update-input
mySupport` on each modification, etc.

However, there are several mechanisms that allows you to temporarily weaken
these constraints for development purposes.

## Packaging a starter module

First, clone the EPNix repository, and package your support module. You can
look at the [Packaging modules](../developer-guide/packaging-modules.md) guide,
by this doesn't even have to compile yet. But, the package does have to specify
the dependencies of your support module.

## Hacking on your module

From the directory of your support module, run:

```bash
nix develop "/path/to/local/epnix#support/mySupport"`
# From the development environment
dontUnpack=true
genericBuild
```

This will put the result of your compilation under `outputs/out`. If you make
modifications to your support module, run `buildPhase` from the same
development environment to recompile it.

## Using it on your EPICS top

Before trying to compile your top, make sure that your support module is
included in the `support.modules` option of your EPNix top:

```nix
support.modules = with pkgs.epnix.support; [ mySupport ];
```

Now that the support module is compiled and installed in a local directory, you
can ask Nix to use it as is. This can be done by running this command from your
EPICS top directory:

```bash
nix develop \
  --override-input epnix '/path/to/local/epnix' \
  --redirect '/path/to/local/epnix#support/mySupport' '/path/to/mySupport/outputs/out'
# Then, normal hacking on an EPICS top...
```

The `--override-input` option instructs Nix to use your local EPNix fork
instead of the one hosted on GitLab. This option is used at flake input level.

The `--redirect` option instructs Nix to use your local directory for your
support module, instead of a module installed in the `/nix/store`. This option
is used as an individual package level.

---

With this setup, you can hack and compile your support module, and the changes
will be directly visible to your top. This enables you to hack on both project
at the same time, each on their own development environment.

One question one may ask:

> What's the difference between running the complex `nix develop` command and
> just putting `/path/to/mySupport/outputs/out` into `RELEASE.local`?

One thing that the complex `nix develop` command does correctly, is replacing
*everything* that would have been `/nix/store/...-mySupport../` into your local
directory. Does does include the `RELEASE.local` file, but this may not be the
only thing.

For example, if you're hacking on the `seq` support module, not only will it
put the path to your local `seq` build into `RELEASE.local`, but it will also
put some `seq` specific programs into your `$PATH`, like the `snc` utility.
These programs will be those from your local build, not the ones coming from
the EPNix repository.
