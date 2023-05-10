---
title: Getting started
---

# Requirements

The requirements for using EPNix are having curl, Nix, and Git installed.

If you need to install Nix, you will also need the `xz` utility, usually part of the "xzip" or "xz" package.

You *do not* need to have EPICS base installed globally, EPNix will make it available to you when you enter your top's development environment.

# Installing Nix

::: callout-warning
If you use a GNU/Linux distribution with SELinux, make sure you disable it.
You can do this by adding the line `SELINUX=disabled` in `/etc/sysconfig/selinux` on RHEL-based distributions like CentOS, Rocky Linux, etc.
:::

If you don't have Nix installed, first follow the [official instructions].

Unless you are using WSL2, we *highly recommend* using the multi-user installation, as it builds packages in a sandboxed environment.

  [official instructions]: https://nixos.org/download.html#download-nix

# Enabling nix flakes and the nix command

Since Nix flakes and the unified `nix` command are quite new, you need to enable them in your `/etc/nix/nix.conf`.

To enable this feature, make sure this line is present in your `/etc/nix/nix.conf`:

``` ini
experimental-features = nix-command flakes
```

Then, if you have installed Nix in multi-user mode, you have to restart the Nix daemon with `systemctl restart nix-daemon.service`{.bash}.

# Untracked files and Nix flakes

One important thing with Nix flakes: when your flake is in a Git repository, Nix will only consider files that Git tracks.

For example, if your `flake.nix`, is in a repository, and you create a file `foobar.txt`, you must run `git add [-N] foobar.txt`{.bash} to make Nix recognize it.

This prevents build products from being copied to the Nix store.

# Concepts

In EPNix, your IOC will have mainly one important file: the `flake.nix` file.

The `flake.nix` file is the entry point that the `nix`{.bash} command will read in order for the `nix build`{.bash}, `nix flake check`{.bash}, `nix develop`{.bash}, etc. commands to work.
It's also the file where you specify your other "repository" dependencies.
For example, your IOC depends on EPNix itself, and also depends on each external EPICS "app."

The `flake.nix` file will also contain the configuration of your EPNix top.
EPNix provides a list of possible options and you can [extend them yourself].
The [Available options] page of the documentation book documents the options provided by EPNix.

  [extend them yourself]: ./adding-options.md
  [Available options]: ../references/options.md

# Creating your project

::: callout-note
This section assumes that you have set up your computer so that you can clone your repositories unattended, with for example SSH keys or tokens.
If you intend to use private git repositories, please check out the [Private repository setup] guide.
:::

With EPNix, we recommend developers to version EPICS tops separate from EPICS apps.
This means that by default, Git will ignore apps created with `makeBaseApp.pl`, so that you can create separate Git repositories for them.

If you use an old system and see git errors while creating your template, you can install a recent version of git by running `nix-env -iA nixpkgs.git` after installing nix.

To kick-start an EPNix project:

``` bash
# Create a new directory by using the EPNix template. It will create the
# aforementioned `flake.nix` which will allow you to specify your base and your
# dependencies. It does not however create your top for you, instead, it will
# provide you with an environment with EPICS base installed (see below).
nix flake new -t 'github:epics-extensions/epnix' my-top
cd my-top

# This will make you enter a new shell, with EPICS base installed in it.
# The EPICS base version will be the one used by your top.
nix develop

# Initializes the EPICS part of your top, and creates a new app
makeBaseApp.pl -t ioc example
# Creates a new iocBoot folder
makeBaseApp.pl -i -t ioc -p example example

# Versioning the top.
# This is highly recommended, since this will make Nix ignore your build
# products in its sandboxed builds
git init
git add .

# Then, create a remote repository for the Top, and push to it
...

# Versioning the app
cd exampleApp
git init
git add .

# Then, create a remote repository for the App, and push to it
...
```

Now that your EPICS app is in a remote repository, you can instruct EPNix to use your created app from the remote repository:

Edit your top's `flake.nix`

-   Below the other inputs, add:

``` nix
inputs.exampleApp = {
  url = "git+ssh://git@your.gitlab.com/your/exampleApp.git";
  flake = false;
};
```

And, under the EPNix options section:

-   add `"inputs.exampleApp"`{.nix} in the `applications.apps` list (the quotes are necessary)

With these steps, Nix will track your app from the remote repository, and track its Git version in the `flake.lock` file.

You can test that your top builds by executing: `nix build -L`{.nix}. This will put a `./result` symbolic link in your top's directory containing the result of the compilation.

::: callout-tip
As a rule of thumb, each time you edit the `flake.nix` file, or update your inputs using `nix flake update`{.bash} or `nix flake lock`{.bash}, you should leave and re-enter your development environment (`nix develop`{.bash}).
:::

  [Private repository setup]: ../guides/private-repo-setup.md

# Developing your IOC

```{=html}
<!-- TODO: Make this section more specific. Leave the details for a guide -->
```
## Using Nix

As said earlier, compiling using Nix is done with `nix build`{.bash}.
This will build your top using your apps from the Git remote repository specified in your flake inputs, all your dependencies, if needed, and place the output under `./result`.

```{=html}
<!-- TODO: Leave that for later -->
<!-- TODO: Show the nix build, edit, nix build, undo, nix build trick -->
```
When developing your IOC, it can become cumbersome that Nix tracks the remote repository of your app.
You will probably want to do some temporary changes to your app, and test them before committing.

For this exact purpose, EPNix comes with a handy command called `enix-local`{.bash}.
This command behaves like `nix`, but will instead use your apps as-is from your local directory.

For example, if you have started your EPNix project as in the [earlier section], you will have your top, with the directory `exampleApp` under it.
Hence, if you run `nix develop`{.bash}, then `enix-local build -L`{.bash} under the development shell, Nix will build your top, with the modifications from your local `exampleApp` directory.

The advantage of using Nix when developing is that it will build from a "cleaner" environment.
It will also store the result in the Nix store, which you can copy using the `nix copy`{.bash} command, and test it on another machine.

  [earlier section]: #creating-your-project

## Using standard tools

The EPNix development shell (`nix develop`{.bash}) comes with your standard build tools installed.
This means that after creating your project, you will be able to use `make`{.bash} as with any other standard EPICS development.

The difference is that Git doesn't track `configure/RELEASE.local` and `configure/CONFIG_SITE.local` files, because they contain variables necessary to build with the EPNix environment.
They contain for example the `EPICS_BASE` variable.
To add them to your top, you can run `eregen-config`{.bash}.

::: callout-tip
As a rule of thumb, each time you edit your modules in `flake.nix`, you should leave and re-enter your development environment, and re-run `eregen-config`{.bash}.
:::

The advantage of using the standard tools, is that the compilation is incremental.
Nix always builds a package fully, meaning it will always compile your top from scratch.
Using `make`{.bash} directly will only recompile the modified files, at the cost of potential impurities in your build.

# Upgrading your app version

Once you have done, tested, committed, and pushed your app changes, you will want to update your top so that your app version points to the latest version.

To do this, you can run:

``` bash
nix flake lock --update-input exampleApp --commit-lock-file
```

This will update the `exampleApp` input, and create a Git commit for this update.

This command also works if you want to update the `epnix` input, or the `nixpkgs` input containing the various needed packages used by EPICS.

# Looking up the documentation

EPNix comes with documentations: it has a documentation book (what you are reading), and man pages.

To see the documentation book, run `edoc`{.bash} in the development shell from your top directory.

To see the man page, run `man epnix-ioc`{.bash} in the development shell from your top directory.

# Adding dependencies

You now should have all the tools you need to have a self-contained EPICS IOC.

However, it's quite useful to depend on code from the community, and EPNix provides a quick way to do it.

The first step is to look at the documentation, either the `epnix-ioc(5)` man page, under the "AVAILABLE PACKAGES" section, or in the documentation book, under the "Available packages" page.

If the package exists, you can add this bit to your `flake.nix` file.

``` nix
support.modules = with pkgs.epnix.support; [ your_dependency ];
```

If the package doesn't exist, you can try [packaging it yourself], or you can request it in the [EPNix issue tracker].

  [packaging it yourself]: ../developer-guides/packaging.md
  [EPNix issue tracker]: https://github.com/epics-extensions/EPNix/issues

# Deploying your IOC

To deploy your IOC, we recommend you build it using Nix.
If you are doing a production deployment, you should make sure that you have a clean build, that is by not using `enix-local`, and having a clean top Git repository.

With this, you get a `./result` symbolic link to the result in the Nix store, which you can copy, with all its dependencies, using `nix copy`.
The only requirement is that the remote machine has Nix installed too.

For example, if you want to copy my built IOC to the machine `example-ioc.prod.mycompany.com`:

``` bash
nix copy ./result --to ssh://root@example-ioc.prod.mycompany.com
```

This will copy the build in the Nix store and every dependencies to the remote machine.

To run the program, you can get where the build is by inspecting the symbolic link on your local machine:

``` bash
readlink ./result
# Returns something like:
# /nix/store/7p4x6kpawrsk6mngrxi3z09bchl2vag1-epics-distribution-custom-0.0.1
```

And then, on the remote machine, you can run the IOC:

``` bash
/nix/store/${SHA}-epics-distribution-custom-0.0.1/bin/linux-x86_64/example
```

If you want to do automated, declarative, or more complex deployments, we highly recommend using NixOS and optionally one of its deployment tools ([NixOps], [morph], [disnix], [colmena]) .
You can also use non-NixOS hosts.

```{=html}
<!-- TODO: create a deployment tutorial. -->
```

  [NixOps]: https://nixos.org/nixops
  [morph]: https://github.com/DBCDK/morph
  [disnix]: https://github.com/svanderburg/disnix
  [colmena]: https://github.com/zhaofengli/colmena

# Pitfalls

Although tries to resemble standard EPICS development, some differences might lead to confusion.
You can see a few usual ones by reading the [FAQ].

You might also be interested in reading [Setting up the flake registry]

  [FAQ]: ../faq.md
  [Setting up the flake registry]: ../guides/flake-registry.md
