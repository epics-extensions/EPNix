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

### Update the flake input

Replace the version of the `nixpkgs` input it <source:flake.nix>,
and run `nix flake lock`.

Create a commit with these changes.
The commit message should be:
{samp}`flake: upgrade NixOS {old.version} -> {new.version}`.

### Update Maven hashes

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

### Apply breaking changes

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

### Document breaking changes

If some breaking changes in Nixpkgs or EPNix affect users,
document them in the release notes,
in {file}`docs/release-notes/{newversion}.rst`.

:::{admonition} Example
If the way Elasticsearch is configured has changed,
add instructions on how to migrate to the new configuration format
in the release notes.
:::

### Fix comments

If there are "TODOs" in the code base that mention the new release,
see if they can be solved.

For example,
if there's a comment {samp}`TODO: remove for NixOS {new.version}`,
remove the comment
and related code block.

Create a commit for each resolved TODO.

### Run the tests

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

## Upgrade EPNix versions

Search for the old EPNix release version,
for example `nixos-24.05`,
and make sure to replace with the newer version,
when appropriate.

You should find at least:

- the `epnix` flake input in <source:templates/top/flake.nix>
- the `stable` and `all` variables in <source:lib/versions.nix>
- the links in the {file}`README.md`
- documentation code examples

:::{admonition} Example
```{code-block} nix
:caption: Updating {file}`templates/top/flake.nix`
:emphasize-lines: 3

{
  # ...
  inputs.epnix.url = "github:epics-extensions/epnix/nixos-24.11";

  # ...
}
```

```{code-block} nix
:caption: Updating {file}`lib/versions.nix`
:emphasize-lines: 4,7

let
  self = {
    current = "dev";
    stable = "nixos-24.11";
    all = [
      "dev"
      "nixos-24.11"
      "nixos-24.05"
      "nixos-23.11"
      "nixos-23.05"
    ];
    # ...
  };
in
  self
```

```{code-block} markdown
:caption: Updating the {file}`README.md`
:emphasize-lines: 2,8,14,15,17,18

EPNix also has release branches,
such as `nixos-24.11`,
tied to the nixpkgs release branches,
where breaking changes are forbidden.

...

[Advantages / disadvantages]: https://epics-extensions.github.io/EPNix/nixos-24.11/advantages-disadvantages.html
[Documentation]: https://epics-extensions.github.io/EPNix/
[EPICS Tech-Talk mailing list]: https://epics.anl.gov/tech-talk/
[EPNix Matrix room]: https://matrix.to/#/#epnix:epics-controls.org
[EPNix repository's discussions]: https://github.com/epics-extensions/EPNix/discussions
[EPNix repository's issue tracker]: https://github.com/epics-extensions/EPNix/issues
[IOC tutorials]: https://epics-extensions.github.io/EPNix/nixos-24.11/ioc/tutorials/index.html
[NixOS services tutorials]: https://epics-extensions.github.io/EPNix/nixos-24.11/nixos-services/tutorials/index.html
[Nix]: https://nixos.org/guides/how-nix-works/
[Packages list]: https://epics-extensions.github.io/EPNix/nixos-24.11/pkgs/packages.html
[Prerequisites]: https://epics-extensions.github.io/EPNix/nixos-24.11/prerequisites.html
```

``````{code-block} markdown
:caption: Updating the Archiver Appliance tutorial
:emphasize-lines: 8,9

```{code-block} nix
:caption: {file}`flake.nix`
:linenos:

{
  description = "Configuration for running Archiver Appliance in a VM";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.epnix.url = "github:epics-extensions/EPNix/nixos-24.11";

  outputs = { self, nixpkgs, epnix }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        epnix.nixosModules.nixos

        ./configuration.nix
      ];
    };
  };
}
```
``````

:::

## Remove the "unreleased" mention in the release notes

In the file {file}`docs/release-notes/{xxyy}.md`,
remove the `(unreleased)` mention on the first line.

## Open a pull request

Once you've verified that the new version is working,
open one or more Pull Requests with your changes on GitHub.

## Create the new release branch

Once your Pull Request is merged,
and you've integrated all changes you want for the new release,
go into GitHub's [branches view],
and create a new {samp}`nixos-{new.version}` branch on `master`.

## Update EPNix versions for that release

Create a new commit
on the new {samp}`nixos-{new.version}` branch,
and update the `current` variable in <source:lib/versions.nix>:

:::{admonition} Example
```{code-block} nix
:caption: Updating {file}`lib/versions.nix` on the new release branch
:emphasize-lines: 3

let
  self = {
    current = "nixos-24.11";
    stable = "nixos-24.11";
    all = [
      "dev"
      "nixos-24.11"
      "nixos-24.05"
      "nixos-23.11"
      "nixos-23.05"
    ];
    # ...
  };
in
  self
```
:::

Also remove the now obsolete <source:.github/workflows/book-gh-pages.yml>,
since the book must be built from the default branch.

Open a Pull Request with that commit,
targeting the {samp}`nixos-{new.version}` branch.

## Build the new version of the documentation

The documentation job might have failed,
since we added {samp}`nixos-{new.version}` in <source:lib/versions.nix>
before creating the branch.

To build the manual,
on GitHub,
click the {menuselection}`Actions tab --> Book GitHub Pages --> Run workflow --> Run workflow`.

## Create the next release notes

Back on the `master` branch,
create a commit that adds the file {file}`docs/release-notes/{xxyy}.md`
for the *future* EPNix version,
with the following content,
while taking care of replacing the version in the first line:

``````{code-block} markdown
# XX.YY Release notes (unreleased)

```{default-domain} nix
```

## Breaking changes

No breaking change were introduced in this EPNix release.

## New features and highlights

## Documentation
``````

[branches view]: https://github.com/epics-extensions/EPNix/branches
[nixos release notes]: https://nixos.org/manual/nixos/stable/release-notes
[nixpkgs]: https://github.com/NixOS/nixpkgs
