# Prerequisites

Before contributing to EPNix,
make sure you follow the general {doc}`../../prerequisites`
and the following requirements.

## Forking

Go to the [EPNix GitHub repository]
and click the {guilabel}`Fork` button.
Choose your account as the owner
and click {guilabel}`Create fork`.

:::{seealso}
GitHub's [Working with forks] documentation.
::::

Go to your forked repository
and clone it:

```{code-block} bash
:caption: Cloning your EPNix fork

git clone "git@github.com:$USER/EPNix.git"
```

To update your EPNix fork in the future,
configure the official EPNix repository
as the `upstream` remote:

```{code-block} bash
:caption: Setting up the EPNix upstream remote

git remote add upstream https://github.com/epics-extensions/EPNix.git
```

:::{tip}
For quick access to your EPNix repository
from the Nix command line,
run:

```{code-block} bash
:caption: Adding the `epnix-local` flake alias

nix registry add 'epnix-local' 'git+file:///path/to/where/you/cloned/epnix'
```

With this setup,
running `nix build "epnix-local#phoebus"` builds the `phoebus` package
from your local EPNix repository,
regardless of your current working directory.
:::

## Create a feature branch

Before creating commits to EPNix,
create an appropriately named branch:

```{code-block} bash
:caption: Creating a feature branch

git switch -c add-asyn-support
```

  [EPNix GitHub repository]: https://github.com/epics-extensions/EPNix/
  [Working with forks]: https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks
