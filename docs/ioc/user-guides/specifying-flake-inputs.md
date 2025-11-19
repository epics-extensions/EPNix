# Specifying flake inputs

:::{tip}
After changing your flake inputs,
make sure you can rebuild your IOC with `nix build -L`,
and re-generate your {file}`RELEASE.local` file
by running `epicsConfigurePhase`
inside a development shell.
:::

:::{seealso}
The [Nix flake] documentation
for the specifications of the flake URL format.
:::

## Point a flake input to a specific branch or tag

To make a flake input point to a specific Git branch,
edit your inputs in {file}`flake.nix`,
and specify the branch in the URL.

### GitHub

To specify the Git branch or tag in a GitHub URL,
the format is {samp}`github:{owner}/{repo}/{branch-or-tag-or-revision}`.

For example:

```{code-block} nix
:caption: Setting the EPNix release branch

  inputs.epnix.url = "github:epics-extensions/EPNix/nixos-25.05";
```

### Generic SSH repository

For an SSH repository,
the format is {samp}`git+ssh://{git-server}/{path/to/repo}?ref={revision}`.

:::{tip}
The `ref` URL parameter here means "reference,"
as in a [Git reference],
which can be a branch name or a tag.

It's different from the `rev` parameter.
:::

For example:

```{code-block} nix
:caption: Setting the branch of a GitLab SSH repo

  inputs.myInput.url = "git+ssh://git@my-gitlab.com/EXAMPLE/myInput.git?ref=myBranch";
```


## Point a flake input to a specific commit

To make a flake input point to a specific Git commit (also called revision),
edit your inputs in {file}`flake.nix`,
and specify the revision in the URL.

This will make sure that this input is never updated
and will stay at the given revision.

### GitHub

To specify the Git revision in a GitHub URL,
the format is {samp}`github:{owner}/{repo}/{branch-or-tag-or-revision}`.

For example:

```{code-block} nix
:caption: Fixing the EPNix revision

  inputs.epnix.url = "github:epics-extensions/EPNix/e040bcef0197ef2d39ab3313cf2bb1f00f61f582";
```

### Generic SSH repository

For an SSH repository,
the format is {samp}`git+ssh://{git-server}/{path/to/repo}?rev={revision}`.

:::{tip}
The `rev` URL parameter here means "revision",
as in a [Git revision],
which must be a commit hash.

It's different from the `ref` parameter.
:::

For example:

```{code-block} nix
:caption: Fixing a GitLab SSH repo

  inputs.myInput.url = "git+ssh://git@my-gitlab.com/EXAMPLE/myInput.git?rev=e040bcef0197ef2d39ab3313cf2bb1f00f61f582";
```

### By reading the lockfile

To find out what locked URL Nix uses,
you can run `nix flake metadata`.

```{code-block} console
$ nix flake metadata

Resolved URL:  git+file:///home/.../myTop
Description:   My super exciting EPICS top
Path:          /nix/store/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-source
Revision:      ...
Last modified: 2025-04-24 16:23:33
Fingerprint:   ...
Inputs:
├───epnix: github:epics-extensions/EPNix/e040bcef0197ef2d39ab3313cf2bb1f00f61f582?narHash=sha256-FBCWeE/tanyKgdwr58o9w%2BKBqQaECMxgwvPuQRDu3zM%3D (2024-02-07 13:50:07)
│   ├───...
│   └───nixpkgs: github:NixOS/nixpkgs/70bdadeb94ffc8806c0570eb5c2695ad29f0e421?narHash=sha256-LWvKHp7kGxk/GEtlrGYV68qIvPHkU9iToomNFGagixU%3D (2024-01-03 14:06:54)
├───...
└───mySupportTop: git+ssh://git@my-gitlab.com/EXAMPLE/mySupportTop.git?ref=refs/heads/main&rev=3d3e3c0fe0aa5d0eaf54ee1b6d019431ae8b6bfa (2024-04-29 11:06:12)
    └───...
```

You can use these URLs in your {file}`flake.nix`,
to prevent updating your flake input by accident.

## Updating flake inputs

See {doc}`dependency-updates`.

  [Git reference]: https://git-scm.com/book/en/v2/Git-Internals-Git-References
  [Git revision]: https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-revision
  [Nix flake]: https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake.html#url-like-syntax
