# Deploying an IOC

## On NixOS

To deploy an IOC on a NixOS machine,
follow the NixOS {doc}`../../nixos-services/user-guides/ioc-services` guide.

## On other Linux systems

### Installing Nix

Nix must be installed on the remote machine
for the following procedure to work.
Follow the EPNix {doc}`../../prerequisites` on the remote machine.

Make sure you can run `nix` commands
from your SSH client
on your development machine:

```{code-block} bash
ssh root@192.168.0.1 nix --version
```

:::{tip}
If it can't find the `nix` command,
add `source /etc/profile.d/nix.sh` to your `~/.bashrc`
or the equivalent for your login shell.
:::

Make sure the `procServ` package is also installed.
As with the EPNix top package,
you can copy it by replacing `.` with `epnix#procServ`
in the following instructions.

### Copy the EPNix top package

From your development machine,
in the EPNix top Git repository,
copy your package:

```{code-block} bash
:caption: Copying the EPNix top package to a remote host

nix copy . --to ssh://root@192.168.0.1
```

If you want to copy EPNix' {nix:pkg}`epnix.procServ` package,
run:

```{code-block} bash
:caption: Copying the `procServ` package to a remote host

nix copy "epnix#procServ" --to ssh://root@192.168.0.1
```

### Symlink the package

Using a {file}`/nix/store/...` path to start an IOC isn't ideal
since it won't be stable across updates.

Still on your development machine,
in the EPNix top Git repository,
symlink the package to a known, stable location
using the `nix-env` utility:

```{code-block} bash
:caption: Remotely creating a symlink to the EPNix package

ssh root@192.168.0.1 "mkdir -p /nix/var/nix/profiles/epnix"
# Find the `/nix/store/...` path of the EPNix top
top_store_path="$(nix eval --raw .)"
ssh root@192.168.0.1 "nix-env --profile /nix/var/nix/profiles/epnix/myTop --set ${top_store_path}"
```

This creates the following file hierarchy:

```text
/nix/var/nix/profiles/epnix
├── myTop -> myTop-1-link
└── myTop-1-link -> /nix/store/...-myTop-...
```

The {file}`/nix/var/nix/profiles/epnix/myTop` symbolic link is the file to use
for the systemd service.

:::{hint}
This set of symbolic links allows you to keep a list of deployments
and roll back to an earlier version of your top,
in a stable location.

Using the `/nix/var/nix/profiles` location also prevents the top
from being garbage collected.
:::

If you want to symbolically link the {nix:pkg}`procServ` package,
run:

```{code-block} bash
:caption: Remotely creating a symlink to the `procServ` package

# Find the `/nix/store/...` path of the EPNix top
procServ_store_path="$(nix eval --raw "epnix#procServ")"
ssh root@192.168.0.1 "nix-env --profile /nix/var/nix/profiles/epnix/procServ --set ${procServ_store_path}"
```

### Configure and start a systemd service

To create a new systemd service,
create the following file,
taking care to replace `myIoc` and `myTop`:

```{code-block} dosini
:caption: {file}`/usr/local/lib/systemd/system/{myIoc}.service`
:emphasize-lines: 2,10,16

[Unit]
Description=My super IOC
Wants=network-online.target
After=network-online.target
StartlimitIntervalSec=0

[Service]
ExecStart=procServ \
  --foreground --oneshot --logfile=- --holdoff=0 \
  --chdir=/nix/var/nix/profiles/epnix/myTop/iocBoot/myIoc \
  2000 \
  ./st.cmd

Restart=always
RestartSec=1s
StateDirectory=epics/myIoc

DynamicUser=true

[Install]
WantedBy=multi-user.target
```

If you installed EPNix' {nix:pkg}`epnix.procServ` package,
replace the `ExecStart=procServ \` line with:

```{code-block} dosini
:caption: Using EPNix' `procServ` package

ExecStart=/nix/var/nix/profiles/epnix/procServ/bin/procServ \
```

Enable and start your IOC with:

```{code-block} bash
systemctl enable --now myIoc.service
```

:::{note}
The `StateDirectory=epics/myIoc` option creates a `/var/lib/epics/myIoc` directory,
with read and write rights for the user running the IOC.

If your IOC creates files,
make sure the destination and the value of `StateDirectory=` corresponds.
:::

### Updating the top

To update your top,
on your development machine,
replace `myTop`
and run:

```{code-block} bash
# Copy the new version of the top
nix copy . --to ssh://root@192.168.0.1

# Make a new symbolic link
top_store_path="$(nix eval --raw .)"
ssh root@192.168.0.1 "nix-env --profile /nix/var/nix/profiles/epnix/myTop --set ${top_store_path}"

# Restart the service
systemctl restart myIoc.service
```

### Managing versions

After upgrading your IOC many times,
the links might look like this:

```text
/nix/var/nix/profiles/epnix
├── myTop -> myTop-4-link
├── myTop-1-link -> /nix/store/...-myTop-...
├── myTop-2-link -> /nix/store/...-myTop-...
├── myTop-3-link -> /nix/store/...-myTop-...
└── myTop-4-link -> /nix/store/...-myTop-...
```

Each {samp}`myTop-{n}-link` point to a deployed version of your top,
and the `myTop` link point to the active version of the top.

To roll back to the previously deployed version,
run:

```{code-block} bash
:caption: Rolling back to the last deployed version

nix-env --profile /nix/var/nix/profiles/epnix/myTop --rollback
```

To delete a specific version,
replace `myTop` and `${version}`,
then run:

```{code-block} bash
:caption: Delete version *version* of the `myTop` deployment

nix-env --profile /nix/var/nix/profiles/epnix/myTop --delete-generation ${version}

# For example
nix-env --profile /nix/var/nix/profiles/epnix/myTop --delete-generation 2
```

To list available versions,
replace `myTop`
and run:

```{code-block} bash
:caption: List available versions of the `myTop` deployment

nix-env --profile /nix/var/nix/profiles/epnix/myTop --list-generations
```
