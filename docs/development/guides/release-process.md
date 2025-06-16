# Release process

This document provides instructions
on how to make a new EPNix release.

EPNix releases are tied to [Nixpkgs] versions,
so one should be made for each Nixpkgs release.

## Read the release notes

Check the [NixOS release notes],
and take note of each change that might affect EPNix.

Breaking changes that might affect EPNix can be:

- Libraries that are used as dependencies of EPNix packages, for example:

  - `open62541` used by the opcua EPICS module
  - Python libraries
  - the Java JDK

- Services used by EPNix services, for example:

  - Elasticsearch, Kafka, FerretDB used by the Phoebus ecosystem

Don't worry about missing breaking changes in the release notes,
running the tests will most likely show whether an incompatible change was introduced.

## Upgrade Nixpkgs

Search for the old release version,
for example *{{versions.stable}}*,
and make sure to replace with the newer version,
when appropriate.

You should find at least:

- the `nixpkgs` flake input in <source:flake.nix>
- the `epnix` flake input in <source:templates/top/flake.nix>
- workflows in <source:.github/workflows/>
- documentation code examples

Once done,
run `nix flake lock`,
and create a commit with these changes.

The commit message should be:
{samp}`flake: upgrade NixOS {old.version} -> {new.version}`.

## Update Maven hashes

Maven hashes might depend on the Java or Maven version used,
so a major Nixpkgs upgrade might cause those hashes to change.

Build the packages that have Maven hashes in them:

```bash
nix build -L \
  '.#channel-finder-service' \
  '.#phoebus-olog' \
  '.#phoebus-deps'
```

And update the hashes accordingly,
if needed.

:::{admonition} Example
```{code-block} diff
:caption: {file}`pkgs/epnix/tools/phoebus/olog/default.nix` -- updating the Maven hash

-  mvnHash = "sha256-xaoaoL1a9VP7e4HdI2YuOUPOADnMYlPesVbkhgLz3+M=";
+  mvnHash = "sha256-puUnYIbBVVXfoIcK9lkmBOH3TBfFAK+MeN8vsoxB8w0=";
```
:::

Create a separate commit for each hash update.

## Apply breaking changes

If there are breaking changes in the Nixpkgs release notes,
apply them when appropriate,
both in the code
and in the documentation.

:::{admonition} Example
If the way MySQL is configured has changed,
reflect those changes in the Archiver Appliance module implementation.
:::

:::{admonition} Example
If the way Elasticsearch is configured has changed,
reflect those changes in the documentation,
in the Phoebus services guides.
:::

Create a commit for each breaking change.

## Document breaking changes

If some breaking changes in Nixpkgs or EPNix affect users,
document them in the release notes,
in {file}`docs/release-notes/{newversion}.rst`.

:::{admonition} Example
If the way Elasticsearch is configured has changed,
add instructions on how to migrate to the new configuration format
in the release notes.
:::

## Fix comments

If there are "TODOs" in the code base that mention the new release,
see if they can be solved.

For example,
if there's a comment {samp}`TODO: remove for NixOS {new.version}`,
remove the comment
and related code block.

Create a commit for each resolved TODO.

## Run the tests

Run the EPNix checks.
This can be done by pushing your branch to DRF's GitLab,
and waiting for the CI to complete.

If you don't have access to DRF's GitLab,
run `nix flake check -L`.

:::{caution}
Running all EPNix checks can take a lot of resources.
:::

If there are issues with some tests,
fix them,
and add a commit for each fix.

## Open a pull request

Once you've verified that the new version is working,
open one or more Pull Requests with your changes on GitHub.

## Create the new release branch

Once your Pull Request is merged,
and you've integrated all changes you want for the new release,
go into GitHub's [branches view],
and create a new {samp}`nixos-{new.version}` branch on master.

## Update the documentation release name

Create a new commit
on the new {samp}`nixos-{new.version}` branch,
and update the `release` variable in <source:docs/conf.py>,
so that it is {samp}`nixos-{new.version}`.

:::{admonition} Example
```{code-block} python
:caption: {file}`docs/conf.py`
:emphasize-lines: 5

project = "EPNix"
copyright = "The EPNix Contributors"
author = "The EPNix Contributors"
release = "dev"
release = "nixos-24.05"
```
:::

Also remove the now obsolete <source:.github/workflows/book-gh-pages.yml>,
since the book must be built from the default branch.

Open a Pull Request with that commit,
targeting the {samp}`nixos-{new.version}` branch.

## Build the new version of the manual

Create a new commit
on the `master` branch,
and update the <source:.github/workflows/book-gh-pages.yml> workflow to clone the newest release:

:::{admonition} Example
```{code-block} yaml
:caption: {file}`.github/workflows/book-gh-pages.yml`
:emphasize-lines: 6-10

      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          ref: master
          path: dev
          persist-credentials: false
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          ref: nixos-24.05
          path: nixos-24.05
          persist-credentials: false
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          ref: nixos-23.11
          path: nixos-23.11
          persist-credentials: false
```
:::

Then add this the version to the build
by changing {file}`pkgs/ci-scripts/build-docs-multiversion.nix`:

:::{admonition} Example
```{code-block} nix
:caption: {file}`pkgs/ci-scripts/build-docs-multiversion.nix`:
:emphasize-lines: 1,4

  stable = "nixos-24.05";
  versions = [
    "dev"
    "nixos-24.05"
    "nixos-23.11"
    # ...
  ];
```
:::

Open a Pull Request with that commit,
targeting the {samp}`master` branch.

[branches view]: https://github.com/epics-extensions/EPNix/branches
[nixos release notes]: https://nixos.org/manual/nixos/stable/release-notes
[nixpkgs]: https://github.com/NixOS/nixpkgs
