---
title: "Pre-requisites"
---

The requirements for using EPNix are having curl, Nix, and Git installed,
either in a Linux system,
or in Windows' WSL2.
Nix must be configured with "flakes" enabled.

You *don't* need to have EPICS base installed globally,
EPNix makes it available to you
when you enter your top's development shell.

Having a global EPICS base installation shouldn't pose any issue.

# Installing Nix

::: callout-warning
If you use a Linux distribution with SELinux,
be sure to turn it off.
You can do this by adding the line `SELINUX=disabled` in `/etc/sysconfig/selinux` on distributions based on RedHat Enterprise Linux (RHEL) like CentOS, Rocky Linux, and so on.
:::

If you don't have Nix installed,
first follow the [official instructions].
Make sure to have the `xz` utility installed beforehand,
often part of the `xzip` or `xz` package.

Unless you use WSL2,
use the multi-user installation,
because it builds packages in an isolated environment.

  [official instructions]: https://nixos.org/download.html#download-nix

# Enabling Nix flakes and the `nix`{.bash} command

Because Nix flakes and the unified `nix` command are experimental features at the time of writing,
you need to enable them in your `/etc/nix/nix.conf`.

To enable this feature,
add this line to your `/etc/nix/nix.conf`:

``` ini
experimental-features = nix-command flakes
```

If you have installed Nix in multi-user mode,
then you have to restart the Nix daemon by running:

``` bash
systemctl restart nix-daemon.service
```

# Untracked files and Nix flakes

One important thing with Nix flakes:
when your flake is in a Git repository,
Nix only considers files that Git tracks.

For example,
if your `flake.nix` is in a Git repository,
and you create a file `foobar.txt`,
you must run `git add [-N] foobar.txt`{.bash} to make Nix recognize it.

This prevents copying build products into the Nix store.

# Git version

If you use an old system and see Git errors when using Nix,
install a recent version of Git by running this:

``` bash
nix-env -iA nixpkgs.git
```

This command installs a recent version of Git for your current user.
