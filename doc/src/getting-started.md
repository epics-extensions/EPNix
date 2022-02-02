# Getting started

## Installing Nix

If you do not have Nix installed, first follow the [official
instructions][install-nix].

[install-nix]: <https://nixos.org/download.html#download-nix>

## Enabling nix flakes and the nix command

Since Nix flakes and the unified `nix` command are quite new, you need to
enable them in your `/etc/nix/nix.conf`. A minimum viable product of Nix flakes
are due to be stabilised during 2022.

To enable this feature, ensure this line is present in your
`/etc/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

Then, if you have installed Nix in multi-user mode, you have to restart the Nix
daemon with `systemctl restart nix-daemon.service`.

## Untracked files and Nix flakes

One important thing with Nix flakes, is that when your flake is in a Git
repository, Nix while only take into account files that are tracked by Git.

For example, if your `flake.nix`, is in a repository, and you create a file
`foobar.txt`, you must `git add [-N] foobar.txt` before trying to build things
with Nix.

This is to prevent build products from being copied unnecessarily to the Nix
store.

## Creating your project

In EPNix, we encourage developers to version EPICS tops separately from EPICS
apps. This means that by default, when execute `makeBaseApp.pl` from your top,
your created app will be ignored by Git, so that you can create its separate
Git repository.

Here's how to kick-start an EPNix project:

```sh
# Create a new top
nix flake new -t 'git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git' my-top
cd my-top
nix develop

# Create a new app
makeBaseApp.pl -t ioc example
makeBaseApp.pl -i -t ioc -p example example

# Versioning the top
git init
git add -N .

# Versioning the app
cd exampleApp
git init
git commit --all --message "initial commit"
# Create a remote repository, and push to it
git remote add origin "git@drf-gitlab.cea.fr:..."
git push
```

Then, instruct EPNix to use your created app from the remote repository:

Edit your top's `flake.nix`

- Below the other inputs, add:

```nix
inputs.exampleApp = {
  url = "git+ssh://git@drf-gitlab.cea.fr/...";
  flake = false;
};
```

Edit your top's `epnix.toml`:

- add `inputs.exampleApp` in `epnix.applications.apps`

With these steps, Nix will track your app from the remote repository, and track
its Git version in the `flake.lock` file.

You can test that your top builds by executing: `nix build -L`. This will put
a `./result` symbolic link in your top's directory containing the result of the
compilation.

**Note:** as a rule of thumb, each time you modify the `epnix.toml` or
`flake.nix`, or update your inputs using `nix flake update` or `nix flake
lock`, you should leave and re-enter your development environment (`nix
develop`).

## Developing your IOC

### Using Nix

As said above, compiling using Nix is as simple as executing `nix build`. This
will build your top using your app from the Git remote repository specified in
your flake inputs, and place the result under `./result`.

But when developing your IOC, and can become cumbersome that Nix only tracks
the remote repository of your app: you will probably want to do some temporary
changes to your app, and test them before committing.

For this exact purpose, EPNix comes with a handy command called `enix-local`.
This command is exactly like `nix`, but will instead use your apps as-is from
your local directory.

For example, if you have started your EPNix project as above, you will have
your top, with the directory `exampleApp` under it. So, if you execute `nix
develop`, then `enix-local build -L` under the development shell, Nix will
build your top, with the modifications from your local `exampleApp` directory.

The advantage of using Nix when developing is that it will build from
a "cleaner" environment, and will store the result in the Nix store, which you
can copy using the `nix copy` command, and test it on another machine.

### Using standard tools

The EPNix development shell (`nix develop`) comes with your standard build
tools installed. This means that after creating your project, you will be able
to use `make` as with any other standard EPICS development.

The only difference is that the `Makefile` and `configure` directory are not
tracked by Git, since they are directly tied to the base, to add them to your
top, simply execute `eregen-config`.

**Note:** as a rule of thumb, each time you modify your modules in
`epnix.toml`, you should leave and re-enter your development environment, and
re-execute `eregen-config`.

The advantage of using the standard tools, is that the compilation is
incremental: Nix always builds a package fully, meaning your top will always be
compiled from scratch if you are using Nix. Using `make` directly will only
recompile the modified files, at the cost of potential impurities in your
build.

## Upgrading your app version

Once you have done, tested, committed, and pushed your app changes, you will
want to update your top so that your app version points to the latest version.

To do this, simply execute:

```bash
nix flake lock --update-input exampleApp --commit-lock-file`
```

This will update the `exampleApp` input, and create a Git commit for this
update.

This command also works if you want to update the `epnix` input, or the
`nixpkgs` input containing the various needed packages used by EPICS.

## Looking up the documentation

EPNix comes with a documentation system, adapted to your project. EPNix comes
with a documentation book (what you are reading), and a manpage.

To see the documentation book execute `edoc` in the development shell, from
your top directory.

To see the manpage, execute `eman` in the development shell, from your top
directory.

## Adding dependencies

You now should have all the tools you need to have a self-contained EPICS IOC.

However, it is quite useful to depend on code from the community, and EPNix
provides a simple way to do it.

The first step is to look at the documentation, either the manpage, under the
"OPTIONS" section, or in the documentation book, under the "Available options"
page.

Then, look for a `epnix.support.<your dependency>` option section. For example,
if you want to add "StreamDevice" as a support module, you can look for options
under `epnix.support.StreamDevice`.

If it exists, you can add this bit to your `epnix.toml` file:

```toml
[epnix.support]
<your dependency>.enable = true
```

If it does not exist, you can check if it is packaged by looking at the
documentation, either in the manpage, under the "AVAILABLE PACKAGES" section,
or in the documentation book, under the "Available packages" page.

If the package exists, you can add this bit to your `epnix.toml` file.

```toml
[epnix.support]
modules = [ "pkgs.epnix.support.<your dependency>" ]
```

If the package does not exist, you can try [packaging it
yourself](./developer-guide/packaging.md), or you can request it in the EPNix
issue tracker.

TODO: link issue tracker

## Deploying your IOC

To deploy your IOC, we recommend you build it using Nix. If you are doing
a production deployment, you should ensure that you have a clean build, i.e. by
not using `enix-local`, and having a clean top Git repository.

With this, you get a `./result` symbolic link to the result in the Nix store,
which you can copy, with all of its dependencies, using `nix copy`. The only
requirement is that the remote machine has Nix installed too.

For example, if I want to copy my built IOC to the machine
`example-ioc.prod.mycompany.com`:

```sh
nix copy ./result --to ssh://root@example-ioc.prod.mycompany.com
```

This will copy the build in the Nix store and all of its dependencies to the
remote machine.

To execute the program, you can get where the build is by inspecting the
symbolic link on your local machine:

```sh
readlink ./result
# Returns something like:
# /nix/store/7p4x6kpawrsk6mngrxi3z09bchl2vag1-epics-distribution-custom-0.0.1
```

And then, on the remote machine, you can execute the IOC:

```sh
/nix/store/<...>-epics-distribution-custom-0.0.1/bin/linux-x86_64/example
```

Of you want to do automated, declarative, or more complex deployments, we
highly recommend you do that using NixOS and one of its deployment tools
([NixOps], [morph], [disnix], [colmena]), or by using leech if you want to use
non-NixOS hosts.

TODO: publish and link leech.

[NixOps]: <https://nixos.org/nixops>
[morph]: <https://github.com/DBCDK/morph>
[disnix]: <https://github.com/svanderburg/disnix>
[colmena]: <https://github.com/zhaofengli/colmena>
