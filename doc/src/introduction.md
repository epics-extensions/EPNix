# Introduction

EPNix (pronunciation: like you are high on mushrooms) is a way of building and
packaging EPICS IOCs using the [Nix] package manager.

By leveraging the Nix package manager, it provides several advantages compared
to packaging EPICS the traditional way:

- Reproducibility: your development environment is the same as your coworker's
  development environment, which is the same as your production
  environment.<sup>1</sup>

- Complete dependencies: your EPICS IOCs ship with the complete set of
  dependencies, allowing you to deploy your IOC without needing to install any
  dependency on the target machine (except for Nix itself).

- Dependency traceability: the version of your dependencies are locked, updated
  manually, and traced in your `flake.lock` file. Combined with code
  versioning, this allows your project to build with the same environment years
  later, and allows you to rollback if one of your dependency becomes
  incompatible.

- Development shell: provides you with a set of tool adapted to your project,
  no matter what you have installed on your machine.

- Declarative configuration: define what you want in your IOC in a declarative
  and extensible manner.

- Unit and integration tests: TODO

<sup>1</sup>: Currently, the epics-base package is not 100% reproducible, some
work is being done towards that.

[Nix]: <https://nixos.org/guides/how-nix-works.html>


## Packaging policy

To be able to specify your dependencies in your EPNix configuration, EPNix
provides a package repository, packaging for example `epics-base`, `asyn`,
`StreamDevice`, and so on.

Only the latest version supported upstream is officially supported in the EPNix
package repository.

However, since your dependencies are "locked", this means you do not need to
upgrade your dependencies if you don't want to. What this means in practice, is
that your IOC repository is using the EPNix project repository at a fixed
commit, like using a repository at a fixed point in time. This commit SHA is
recorded in the `flake.lock` file, which should be checked out in your Git
repository.


### The epics-base package

Currently the epics-base package has no significant modification compared to
the upstream version at [Launchpad][upstream].

[upstream]: <https://git.launchpad.net/epics-base>
