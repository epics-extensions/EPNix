# Introduction

% TODO: rewrite this into an introduction to the EPICS IOC part of EPNix

EPNix (pronunciation: like you are high on mushrooms) provides a way of building and packaging EPICS IOCs using the [Nix] package manager.

By leveraging the Nix package manager,
it provides several advantages compared to packaging EPICS the traditional way:

Reproducibility:
: Your development environment is the same as your coworker’s development environment, which is the same as your production environment.

Complete dependencies:
: Your EPICS IOCs ship with the complete set of dependencies, which means you can to deploy your IOC without needing to install any dependency on the target machine (except for Nix itself).

Dependency traceability:
: The version of your dependencies are locked, updated manually, and traced in your `flake.lock` file.
  Combined with code versioning, you can build your project with the same environment years later, and you can roll back to any earlier version.

Development shell:
: Provides you with a set of tools adapted to your project, no matter what you have installed on your machine.

Declarative configuration:
: Define what you want in your IOC in a declarative and extendable manner.

Integration tests:
: Write tests using Python, by starting a virtual machine with your IOC running.

## Packaging policy

To be able to specify your dependencies in your EPNix configuration, EPNix provides a package repository, packaging for example `epics-base`, `asyn`, `StreamDevice`, etc.

In its package repository, EPNix officially supports the latest upstream version.

However, since Nix "locks" your dependencies, this means you don’t need to upgrade your dependencies if you don’t want to.
What this means in practice: your IOC repository uses the EPNix project repository at a fixed commit, like using a repository at a fixed point in time.
Nix records this commit SHA in the `flake.lock` file, which should be checked out in your Git repository.

### The epics-base package

The epics-base package has no significant modification compared to the upstream version on [GitHub].
One goal of EPNix is to keep those modifications to a minimum, and upstream what’s possible.

[github]: https://github.com/epics-base/epics-base/
[nix]: https://nixos.org/guides/how-nix-works.html
