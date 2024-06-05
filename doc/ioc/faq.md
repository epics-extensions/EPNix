---
title: Frequently Asked Questions
---

# I am getting weird Git errors about an unknown `-C` option

You may be using a system with an old version of Git.
You may install a recent version of Git for your user by running `nix-env -iA nixpkgs.git`{.bash}.

# A file I created isn't found when I run `nix build`{.bash}

If your top is a Git repository, you must `git add`{.bash} those files to make them recognized by Nix.

# An App can't find a build product from another App

EPNix enables parallel builds by default.
These means that if App dependencies aren't specified, these Apps will compile in no particular order.
Use `<consumerApp>_DEPEND_DIRS += <producerApp>`{.makefile} in your top-level `Makefile`.

# How do I version a whole EPNix top?

Meaning, not versioning an App separate from the top.
This might be justified if you don't intend to share an App in any other top.

1.  First, create a top and an App, as in the [StreamDevice tutorial].

2.  Make sure to add an exception for the `exampleApp` folder at the end of the top's `.gitignore` file:

``` ini
...
# Applications and Support modules should be an EPNix dependency in flake.nix
*App
*Sup
# You can add exceptions like this:
# ---
#!myCustomLocalApp
!exampleApp
```

3.  Then, version both the top and the App:

``` bash
git init
git add -N .
```

4.  Finally, in your `flake.nix`, you can remove any input and value in `epnix.applications.apps` that refers to this directory.

  [StreamDevice tutorial]: ./tutorials/streamdevice.md
