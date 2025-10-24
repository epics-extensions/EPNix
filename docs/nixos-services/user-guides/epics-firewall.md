# EPICS firewall

:::{important}
This module uses the default Channel Access and pvAccess ports.
If you use non-default Channel Access or pvAccess ports,
you need to write your own firewall rules manually.
You can read the source code of the EPNix EPICS firewall module
as a starting point: <source:nixos/modules/epics-environment.nix>.
:::

## Open the firewall for EPICS IOCs

:::{tip}
If your firewall is enabled,
which is the default on NixOS,
you need to use these options
to make your IOC reachable on the network.
:::

You can open the firewall
to allow access to EPICS IOCs
by using {nix:option}`environment.epics.openCAFirewall` for Channel Access
and {nix:option}`environment.epics.openPVAFirewall` for pvAccess.

## pvAccess clients


:::{warning}
For pvAccess,
clients behind a firewall will only be able to see IOCs based on PVXS,
*not* IOCs based on epics-base's pvAccess.

This is because epics-base's pvAccess
opens a random port
when replying to search requests,
which is considered to be a different connection
by the firewall.

See [pvAccess issue 159](https://github.com/epics-base/pvAccessCPP/issues/159).
:::

## Allow broadcast searches

### On NixOS

If you enable the "auto address list"
or if you add a broadcast address to the "address list",
your Channel Access or pvAccess client will search PVs
on your network via broadcasting.

Using the options {nix:option}`environment.epics.allowCABroadcastDiscovery` (For CA)
and {nix:option}`environment.epics.allowPVABroadcastDiscovery` (For PVA)
allows broadcast search response to go through the firewall.

These options must be used on the EPICS client side.
This can be for example
a machine:

- that does `caget` and `caput`,
- with Phoebus installed
- with any EPICS service installed (such as Archiver Appliance, Phoebus alarm, etc.),
- or an EPICS IOC which uses external PVs from the network.

:::{danger}
This option is a security issue
and attackers crafting a malicious packet from source port 5064
will be able to access any [Ephemeral port]
of this machine.
:::

### On non-NixOS

If your client is a non-NixOS system
you need to add these firewall rules manually.

Read your distribution and firewall documentation
and add those rules on your client machine:

- for Channel Access: allow *source* port 5064 and destination port between 32768 and 60999
- for pvAccess: allow *source* port 5076 and destination port between 32768 and 60999

:::{tip}
Make sure your rules allow the *source* port 5064 and 5076,
not the *destination* port.
:::

:::{danger}
This option is a security issue
and attackers crafting a malicious packet from source port 5064
will be able to access any [Ephemeral port]
of this machine.
:::

  [Ephemeral port]: https://en.wikipedia.org/wiki/Ephemeral_port
