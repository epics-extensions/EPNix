# Phoebus ecosystem VM

EPNix provides a "Phoebus ecosystem" virtual machine
that has most of the Phoebus-related services,
such as:

- Archiver Appliance,
- ChannelFinder,
- Phoebus Olog,
- Phoebus alarm logger,
- Phoebus save-and-restore,
- all services needed by the Phoebus ecosystem, such as Kafka, Elasticsearch,
- and a demo EPICS IOC.

You can run this configuration either in a QEMU VM,
or in a VirtualBox VM.

## QEMU

To run the VM under QEMU,
run:

```bash
nix run -L "github:epics-extensions/EPNix#phoebus-ecosystem/qemu-vm"
```

This command will build all the Phoebus services
and run QEMU with the proper options for starting the VM
with the services port-forwarded.

This command also creates a {file}`phoebus-ecosystem.qcow2` disk image file
in the directory you run it.
This file is the hard-drive of the VM
and can be safely deleted to restart from scratch.

## VirtualBox

To run the VM under VirtualBox,
build the Open Virtual Appliance (OVA) file:

```bash
nix build -L "github:epics-extensions/EPNix#phoebus-ecosystem/virtualbox-image"
```

:::{caution}
Besides building all Phoebus services,
building the OVA file itself can be resource intensive,
being CPU, RAM, or disk I/O.
Make sure to run this build on a machine
that has enough of those resources available.
:::

After running the command,
you can find the OVA file under {file}`result/phoebus-ecosystem-epnix-{version}.ova`

To import it,
open VirtualBox and select {menuselection}`File --> Import Appliance…`,
or press {kbd}`Ctrl-I`.
Select the built OVA file,
choose its name and where to import it,
and click {guilabel}`Finish`.

:::{note}
Before running the VM,
make sure no program on your local machine listens
to the ports documented in {ref}`phoebus-ecosystem-ports`.

The VirtualBox VM has been known to sometimes have boot issues.
If this happens, keep reboot the VM.

If you have NAT or port-forwarding issues,
restart VirtualBox in its entirety.
:::

## Exposed services

The VM port-forwards the following services:

<!--
  When modifying this list,
  make sure to also modify `nixos/phoebus-ecosystem/configuration.nix`.
-->

::::::{table} Port-forwarded ports of the Phoebus ecosystem VM
:name: phoebus-ecosystem-ports

:::{list-table}
:header-rows: 1

- * Service
  * Port
  * Link
- * [Archiver Appliance](https://epicsarchiver.readthedocs.io/en/stable/)
  * 8080
  * [Archiver web UI](http://localhost:8080/mgmt/ui/index.html)
- * [Phoebus alarm logger](https://control-system-studio.readthedocs.io/en/stable/services/alarm-logger/doc/index.html)
  * 8081
  * [Alarm logger status](http://localhost:8081/)
- * [Phoebus save-and-restore](https://control-system-studio.readthedocs.io/en/stable/services/save-and-restore/doc/index.html)
  * 8082
  * [Save-and-restore status](http://localhost:8082/save-restore/)
- * [Phoebus Olog](https://olog.readthedocs.io/en/latest/)
  * 8083
  * [Olog status](http://localhost:8083/Olog/)
- * [ChannelFinder](https://channelfinder.readthedocs.io/en/latest/)
  * 8084
  * [ChannelFinder web UI](http://localhost:8084/)
- * Apache Kafka
  * 9092
  * *none*
- * Example EPICS IOC
  * 5064 (TCP and UDP)
  * [IOC `.db` configuration](source:nixos/phoebus-ecosystem/ioc/exampleApp/Db/example.db)
- * SSH
  * 2222
  * *none*
:::
::::::

To use those services with a local Phoebus client instance,
use the provided {download}`phoebus-ecosystem-settings.ini`.

To connect to the VM,
you can log in as `root` from the VM window.

You can also log in through SSH by running the following command:

```bash
ssh root@localhost -p 2222
```

:::{tip}
Recreating the VM will change its SSH host key.
To remove the old one,
run:

```bash
ssh-keygen -R '[localhost]:2222'
```
:::
