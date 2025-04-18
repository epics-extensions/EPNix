# Frequently Asked Questions

## I am getting weird Git errors about an unknown `-C` option

You may be using a system with an old version of Git.
You may install a recent version of Git for your user by running `nix-env -iA nixpkgs.git`.

## A file I created isn’t found when I run `nix build`

If your top is a Git repository, you must `git add` those files to make them recognized by Nix.

## An App can’t find a build product from another App

EPNix enables parallel builds by default.
These means that if App dependencies aren’t specified, these Apps will compile in no particular order.
Use `<consumerApp>_DEPEND_DIRS += <producerApp>` in your top-level `Makefile`.
